
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <mmdeviceapi.h>
#include <audioclient.h>
#include <ksmedia.h>

#include <atomic>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <thread>
#include <vector>
#include <algorithm>
#include <cmath>

#include <cstring>
#include <stdexcept>
#include <string>

#pragma comment(lib, "ole32.lib")
#pragma comment(lib, "uuid.lib")

std::atomic<bool> running{true};

void write16(std::ofstream &f, uint16_t v)
{
    f.put(static_cast<char>(v));
    f.put(static_cast<char>(v >> 8));
}

void write32(std::ofstream &f, uint32_t v)
{
    write16(f, static_cast<uint16_t>(v));
    write16(f, static_cast<uint16_t>(v >> 16));
}

void writeHeader(std::ofstream &f, uint32_t rate, uint32_t bytes)
{
    f.seekp(0);
    f.write("RIFF", 4);
    write32(f, 36 + bytes);
    f.write("WAVEfmt ", 8);
    write32(f, 16);
    write16(f, 1); // PCM
    write16(f, 2); // stereo
    write32(f, rate);
    write32(f, rate * 4);
    write16(f, 4);  // block align
    write16(f, 16); // bits per sample
    f.write("data", 4);
    write32(f, bytes);
}

bool isFloatFormat(const WAVEFORMATEX *fmt)
{
    if (fmt->wFormatTag == WAVE_FORMAT_IEEE_FLOAT)
    {
        return true;
    }

    if (fmt->wFormatTag == WAVE_FORMAT_EXTENSIBLE &&
        fmt->cbSize >= 22)
    {
        auto ext = reinterpret_cast<const WAVEFORMATEXTENSIBLE *>(fmt);
        return IsEqualGUID(
            ext->SubFormat, KSDATAFORMAT_SUBTYPE_IEEE_FLOAT);
    }

    return false;
}

bool isPcmFormat(const WAVEFORMATEX *fmt)
{
    if (fmt->wFormatTag == WAVE_FORMAT_PCM)
        return true;

    if (fmt->wFormatTag == WAVE_FORMAT_EXTENSIBLE &&
        fmt->cbSize >= 22)
    {
        auto ext = reinterpret_cast<const WAVEFORMATEXTENSIBLE *>(fmt);
        return IsEqualGUID(ext->SubFormat, KSDATAFORMAT_SUBTYPE_PCM);
    }

    return false;
}

float readSample(const BYTE *p, unsigned bits, bool isFloat)
{
    if (isFloat && bits == 32)
    {
        float v;
        memcpy(&v, p, sizeof(v));
        return std::isfinite(v) ? std::clamp(v, -1.0f, 1.0f) : 0.0f;
    }

    if (isFloat)
    {
        throw std::runtime_error("Unsupported float format");
    }

    if (bits == 16)
    {
        int16_t v;
        memcpy(&v, p, sizeof(v));
        return v / 32768.0f;
    }

    if (bits == 24)
    {
        int32_t v = int32_t(p[0]) |
                    (int32_t(p[1]) << 8) |
                    (int32_t(p[2]) << 16);
        if (v & 0x800000)
            v |= ~0xFFFFFF;
        return v / 8388608.0f;
    }

    if (bits == 32)
    {
        int32_t v;
        memcpy(&v, p, sizeof(v));
        return static_cast<float>(v / 2147483648.0);
    }

    throw std::runtime_error("Unsupported PCM format");
}

int16_t toPcm16(float v)
{
    v = std::clamp(v, -1.0f, 1.0f);
    return static_cast<int16_t>(std::lrint(v * 32767.0f));
}

int main(int argc, char **argv)
{
    if (argc < 2)
    {
        std::cerr << "Usage: audio_capture.exe output.wav\n";
        return 1;
    }

    const char *path = argv[1];

    HRESULT hr = CoInitializeEx(nullptr, COINIT_MULTITHREADED);
    if (FAILED(hr))
    {
        std::cerr << "COM initialization failed\n";
        return 2;
    }

    IMMDeviceEnumerator *enumerator = nullptr;
    IMMDevice *device = nullptr;
    IAudioClient *client = nullptr;
    IAudioCaptureClient *capture = nullptr;
    WAVEFORMATEX *fmt = nullptr;

    auto cleanup = [&]()
    {
        if (capture)
            capture->Release();
        if (client)
            client->Release();
        if (fmt)
            CoTaskMemFree(fmt);
        if (device)
            device->Release();
        if (enumerator)
            enumerator->Release();
        CoUninitialize();
    };

    hr = CoCreateInstance(
        __uuidof(MMDeviceEnumerator), nullptr, CLSCTX_ALL,
        __uuidof(IMMDeviceEnumerator),
        reinterpret_cast<void **>(&enumerator));

    if (FAILED(hr))
    {
        std::cerr << "Cannot create device enumerator\n";
        cleanup();
        return 3;
    }

    hr = enumerator->GetDefaultAudioEndpoint(eRender, eConsole, &device);
    if (FAILED(hr))
    {
        std::cerr << "No default output device\n";
        cleanup();
        return 4;
    }

    hr = device->Activate(
        __uuidof(IAudioClient), CLSCTX_ALL, nullptr,
        reinterpret_cast<void **>(&client));

    if (FAILED(hr))
    {
        std::cerr << "Cannot open audio client\n";
        cleanup();
        return 5;
    }

    hr = client->GetMixFormat(&fmt);
    if (FAILED(hr) || !fmt)
    {
        std::cerr << "Cannot get audio format\n";
        cleanup();
        return 6;
    }

    const bool floatFormat = isFloatFormat(fmt);
    if ((!floatFormat && !isPcmFormat(fmt)) ||
        (floatFormat && fmt->wBitsPerSample != 32) ||
        (!floatFormat && fmt->wBitsPerSample != 16 &&
         fmt->wBitsPerSample != 24 && fmt->wBitsPerSample != 32) ||
        fmt->nChannels == 0 ||
        fmt->nBlockAlign == 0)
    {
        std::cerr << "Unsupported device audio format\n";
        cleanup();
        return 7;
    }

    hr = client->Initialize(
        AUDCLNT_SHAREMODE_SHARED,
        AUDCLNT_STREAMFLAGS_LOOPBACK,
        10000000, // 1 second buffer
        0,
        fmt,
        nullptr);

    if (FAILED(hr))
    {
        std::cerr << "WASAPI Initialize failed: 0x"
                  << std::hex << hr << "\n";
        cleanup();
        return 8;
    }

    hr = client->GetService(
        __uuidof(IAudioCaptureClient),
        reinterpret_cast<void **>(&capture));

    if (FAILED(hr))
    {
        std::cerr << "Cannot open capture buffer\n";
        cleanup();
        return 9;
    }

    std::ofstream out(path, std::ios::binary);
    if (!out)
    {
        std::cerr << "Cannot create output WAV\n";
        cleanup();
        return 10;
    }

    // Reserve space for the WAV header.
    char blank[44] = {};
    out.write(blank, sizeof(blank));

    std::thread inputThread([]
                            {
        std::string line;
        std::getline(std::cin, line);
        running = false; });

    std::cout << "Recording system audio. Press Enter to stop.\n";

    uint64_t dataBytes = 0;
    const unsigned bytesPerSample = fmt->wBitsPerSample / 8;

    hr = client->Start();
    if (FAILED(hr))
    {
        running = false;
        if (inputThread.joinable())
            inputThread.join();
        std::cerr << "Cannot start capture\n";
        out.close();
        cleanup();
        return 11;
    }

    while (running)
    {
        UINT32 packetFrames = 0;
        hr = capture->GetNextPacketSize(&packetFrames);
        if (FAILED(hr))
            break;

        if (packetFrames == 0)
        {
            Sleep(5);
            continue;
        }

        BYTE *data = nullptr;
        UINT32 frames = 0;
        DWORD flags = 0;

        hr = capture->GetBuffer(
            &data, &frames, &flags, nullptr, nullptr);
        if (FAILED(hr))
            break;

        std::vector<int16_t> converted;
        converted.reserve(static_cast<size_t>(frames) * 2);

        for (UINT32 i = 0; i < frames; ++i)
        {
            float samples[2] = {0.0f, 0.0f};

            if (!(flags & AUDCLNT_BUFFERFLAGS_SILENT))
            {
                const BYTE *frame = data + i * fmt->nBlockAlign;

                for (unsigned ch = 0;
                     ch < std::min<unsigned>(fmt->nChannels, 2);
                     ++ch)
                {
                    samples[ch] = readSample(
                        frame + ch * bytesPerSample,
                        fmt->wBitsPerSample, floatFormat);
                }

                if (fmt->nChannels == 1)
                {
                    samples[1] = samples[0];
                }
            }

            converted.push_back(toPcm16(samples[0]));
            converted.push_back(toPcm16(samples[1]));
        }

        const auto bytes =
            static_cast<std::streamsize>(
                converted.size() * sizeof(int16_t));

        out.write(reinterpret_cast<const char *>(converted.data()), bytes);
        dataBytes += static_cast<uint64_t>(bytes);

        capture->ReleaseBuffer(frames);
    }

    client->Stop();
    running = false;
    if (inputThread.joinable())
        inputThread.join();

    out.flush();
    writeHeader(out, fmt->nSamplesPerSec,
                static_cast<uint32_t>(
                    std::min<uint64_t>(dataBytes, 0xFFFFFFFFu - 36)));
    out.close();

    std::cout << "Saved: " << path << "\n";
    cleanup();
    return 0;
}
