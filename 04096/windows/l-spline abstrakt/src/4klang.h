// some useful song defines for 4klang
#define EMPTY_WAIT 8*65536

#define SAMPLE_RATE 44100
#define BPM 160.000000
#define MAX_INSTRUMENTS 6
#define MAX_PATTERNS 70
#define PATTERN_SIZE_SHIFT 4
#define PATTERN_SIZE (1 << PATTERN_SIZE_SHIFT)
#define MAX_TICKS (MAX_PATTERNS*PATTERN_SIZE)
#define SAMPLES_PER_TICK 4134
#define MAX_SAMPLES (SAMPLES_PER_TICK*MAX_TICKS+EMPTY_WAIT)
#define POLYPHONY 1
#define FLOAT_32BIT
#define SAMPLE_TYPE float

#define WINDOWS_OBJECT

// declaration of the external synth render function, you'll always need that
extern "C" void  __stdcall	_4klang_render(void*);
// declaration of the external envelope buffer. access only if you're song was exported with that option
extern "C" float _4klang_envelope_buffer;
// declaration of the external note buffer. access only if you're song was exported with that option
extern "C" int   _4klang_note_buffer;