unit wavmid;

interface

uses MainDefs;

{Midi-Teil}
procedure PlayMIDI(Addr:Pointer;MiMu:Real);
procedure closemidi;{stoppt midiausgabe}
function playing:boolean; {Gibt an, ob noch Midi abgespielt wird}

{intern}
procedure MidMyInt08;{interrupt;}

PROCEDURE AddSFX(Nr,Tone,Vol,Len,MaxA:LongInt);
PROCEDURE CalcSFX(Ticks:LongInt);
Procedure SetProgram(Channel,Inst:Byte);
Procedure SetNoteOn(Channel,Note,Volume:Byte);
Procedure SetNoteOff(Channel,Note,Volume:Byte);
Procedure ResetGM;
CONST
  GMPort:Word        = $331;
  MusOn:Boolean=False;

CONST MidiTempo:LongInt=300;

VAR
    MidMul,KritWert:Real;

implementation

const dma=3000;
      MinChan=13;
      MaxChannels=15;

VAR I,K,M:LongInt;
    SFX:ARRAY[MinChan..MaxChannels]OF RECORD
                                    Busy:Boolean;
                                    No,Ton:LongInt;
                                    PlayTime:LongInt;
                                  END;
    SFXAnz:LongInt;

Const
  Send          = $80;
  Receive       = $40;

{ AL:=Command; }
Procedure WriteGMCommand; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ;Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    {; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    OUT   DX,AL                       {;Send Data                         }
End;

{ ; AL:=Data }
Procedure WriteGM; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Receive                  {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                     }
    OUT   DX,AL                       {;Send Data                        }
End;

{ ;Returns Data }
Function ReadGM:Byte; Assembler;
ASM
    MOV   DX,GMPort                   {;DX:=GMStatusPort;                 }
    PUSH  AX                          {;Save AX                           }
    XOR   AX,AX                       {;AH:=TimeOutValue;                 }
@@WaitLoop:
    { ; Prevent Infinite Loop with Timeout }
    DEC   AH                          {; |If TimeOutCount=0 then          }
    JZ    @@TimeOut                   {;/   TimeOut;                      }
    { ; Wait until GM is ready }
    IN    AL,DX                       {; |If Not Ready then               }
    AND   AL,Send                     {; |  WaitLoop;                     }
    JNZ   @@WaitLoop                  {;/                                 }
@@TimeOut:
    POP   AX                          {;Restore AX                        }

    DEC   DX                          {;DX:=DataPort                      }
    IN    AL,DX                       {;Receive Data                      }
End;

Procedure ResetGM; Assembler;
ASM
    { ;Reset GM }
    MOV   DX,GMPort
    MOV   AL,0FFh
    OUT   DX,AL
    {; Get ACK }
    CALL  ReadGM
    {; UART Mode }
    MOV   AL,03Fh
    CALL  WriteGMCommand
End;

Procedure SetProgram(Channel,Inst:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,$c0
    Call  WriteGM
    MOV   AL,[Inst]
    CALL  WriteGM
End;

Procedure SetNoteOn(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,90h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;

Procedure SetNoteOff(Channel,Note,Volume:Byte); Assembler;
ASM
    MOV   AL,[Channel]
    ADD   AL,80h
    Call  WriteGM
    MOV   AL,[Note]
    CALL  WriteGM
    MOV   AL,[Volume]
    CALL  WriteGM
End;
{Midi-Teil}

type TChunk=record
       sign:array[1..4] of char;
       size:record High,Low:word;end;
     end;

     TMidiHeader=record
       FileFormat:word;
       TrackCount:word;
       Ticks:word;
     end;

     PTChunkData=^TChunkData;
     TChunkData=array[0..65532] of byte;

     TTrack=record
       size:word;
       data:PTChunkData;
       index:word;
       Last:byte;
       Timer:Longint;
     end;

     TTracks=array[1..100] of TTrack;

const

      {Instrument- und Notendefinitionen}
      Notes:array[0..11] of word=
      ($157,$16B,$181,$198,$1B0,$1CA,$1E5,$202,$220,$241,$263,$287);

      DrumChannels=[9]; { 10 ? 9..10 ? ????? }

      PercussiveVoice:array[0..4] of byte=(6,7,8,8,7);

const ticks:word=0;
      TrackCount:word=0;
      ChunkIndex:word=0;
      Tempo:longint=0;
      MidiCounter:longint=0;
      ClockTicks:longint=0;

var tracks,StartTracks:^TTracks;

    orgint08:procedure;

    {NoteOn info}
    Channels:array[0..15] of record
                               Instr:byte;
                               Voice:array[0..127] of byte;
                             end;

    {SBVoice Info}
    Voices:array[0..8] of record
                            Channel:byte;
                            Note:byte;
                            Time:longint;
                          end;

    {Hier werden dann die Instrumen-Informationen gespeichert}
    Instrs:array[0..15] of byte;

{List einen Midi-Chunk aus der Datei}
function ReadChunk(sign:string;var chunk:TChunk):boolean;

begin
  LoadMem(@Chunk,SizeOf(tChunk));
  ReadChunk:=(chunk.sign=sign) and (chunk.size.high=0);
  chunk.size.low:=swap(chunk.size.low);
end;

{Liest einen Midi-Chunk aus dem Speicher}
procedure GetChunk(var chunkdata:PTChunkData;chunksize:word);

begin
  getmem(chunkdata,chunksize);
  LoadMem(ChunkData,ChunkSize);
  chunkindex:=0;
end;

{Gibt den Speicher von einem Chunk wieder frei}
procedure FreeChunk(var chunkdata:PTChunkData;chunksize:word);

begin
  freemem(chunkdata,chunksize);
end;

{Errechnet die Zeit, nach der dieser Chunk abgespielt wird}
Function ChunkTimer(Chunkdata:PTChunkData):longint;

var Timer:longint;
    b:byte;

begin
  Timer:=0;
  Repeat
    b:=ChunkData^[ChunkIndex];
    inc(ChunkIndex);
    Timer:=Timer shl 7 + (b and $7F);
  until b<128;
  ChunkTimer:=Timer;
end;

{Liest aus einer g�ltigen Midi-Datei alle wichtigen Daten in den Speicher}
PROCEDURE ReadMidi;

var chunk:TChunk;
    ChunkData:PTChunkData;
    i:integer;

begin
  readchunk('MThd',chunk);
    {File Header}
    getchunk(ChunkData,chunk.size.low);
    TrackCount:=swap(TMidiHeader(pointer(Chunkdata)^).TrackCount);
    ticks:=swap(TMidiHeader(pointer(ChunkData)^).ticks);
    tempo:=600;
    freechunk(ChunkData,chunk.size.low);

    {Tracks};
    getmem(Tracks,TrackCount*sizeof(TTrack));
    getmem(StartTracks,TrackCount*sizeof(TTrack));
    fillchar(Tracks^,trackcount*sizeof(TTrack),0);

    for i:=1 to TrackCount do
    begin
      if not ReadChunk('MTrk',chunk) then exit;

      getchunk(ChunkData,chunk.size.low);
      with tracks^[i] do
      begin
        size:=chunk.size.low;
        data:=chunkdata;
        Timer:=ChunkTimer(Chunkdata);
        Index:=Chunkindex;
        Last:=$FF;
      end;
      StartTracks^[I]:=Tracks^[I];
    end;
end;

{Setzt ein neues Instrument}

{Beendet einen Ton}
procedure NoteOff(Channel,Note,Velocity:word);

var voice:byte;

begin
  voice:=Channels[Channel].Voice[Note];
  if Voice=255 then exit;

  Channels[Channel].Voice[Note]:=255;
  Voices[Voice].Channel:=255;

  SetNoteOff(Channel,Note,Velocity);
end;

{Spielt einen Ton}
procedure NoteOn(Channel,Note,Velocity:word);

label break;

var Drum:boolean;
    voice:byte;
    oldest:longint;
    n,o:word;

begin

  Drum:=(Channel in DrumChannels) and (Instrs[Channel]<5);
  If Drum then Voice:=PercussiveVoice[Instrs[Channel]]
  else
  begin
    voice:=0;
    oldest:=Voices[Voice].Time;

    For n:=0 to 5 do
    begin
      if Voices[N].Channel=255 then
      begin
        Voice:=N;
        goto break;
      end;
      if Voices[N].Time<Oldest then
      begin
        Voice:=N;
        Oldest:=Voices[N].Time;
      end;
    end;
    break:
  end;

  With Voices[Voice] do if Channel<255 then NoteOff(Channel,Note,0);

  Channels[Channel].Voice[Note]:=Voice;

  Voices[Voice].Channel:=Channel;
  Voices[Voice].Note:=Note;
  Voices[Voice].Time:=MidiCounter;

{  SetInstrument(Drum,Voice,Instrs[Channel],Velocity);}
  SetNoteOn(Channel,Note,Velocity);
end;

{Nur intern}
{Procedure SetVolume(Channel,Note,Velocity:word);

var Voice:byte;
    Drum:boolean;

begin
  ASM mov ax,3;int 10h; END;
  Voice:=Channels[Channel].Voice[Note];
  if Voice=255 then exit;
  Drum:=(Channel in DrumChannels) and (Instrs[Channel]<5);
  SetProgram(Voice,Instrs[Channel]);
end;}

{Spielt einen Track von Midi ab}
Procedure PlayTrack(i:integer);

var wait,dly,newtimer:longint;
    event,channel,note,velocity,meta,b:byte;
    metasize:word;
    K,M:LongInt;

begin
  With Tracks^[i] do
  begin
    Event:=Data^[Index];
    if Event<$80 then Event:=Last else begin Last:=Event;Inc(Index);end;

    Case Event shr 4 of
      $8:begin {Note Off }
           Channel:=Event and $F;
           Note:=Data^[Index];
           inc(index);
           Velocity:=Data^[Index];
           inc(index);
           NoteOff(Channel,Note,Velocity);
         end;

      $9:begin {Note On }
           Channel:=Event and $F;
           Note:=Data^[Index];
           inc(index);
           Velocity:=Data^[Index];
           inc(index);
           if Velocity=0 then NoteOff(Channel,Note,Velocity) else NoteOn(Channel,Note,Velocity);
         end;

      $A:begin { Key Aftertouch - only supported for GM device }
{           Channel:=Event and $F;
           Note:=Data^[Index];}
           inc(index,2);
{           Velocity:=Data^[Index];
           inc(index);
{           SetVolume(Channel,Note,Velocity);}
         end;

      $C:begin { Patch change - this changes the instrument on a channel }
           Channel:=Event and $F;
           Instrs[Channel]:=Data^[Index];
           SetProgram(Channel,Instrs[Channel]);
           inc(Index);
         end;

      $D:begin { Channel aftertouch - only supported on GM device }
          Inc(Index);
         end;

      $B,$E:begin { Pitch wheel change - only supported on GM device }
           Inc(Index,2);
         end;

      $F:begin
           Meta:=Data^[Index];
           inc(Index);

           MetaSize:=0;
           Repeat
             b:=Data^[Index];
             inc(index);
             MetaSize:=MetaSize shl 7 + (b and $7f);
           Until b<128;

           Case Meta of
             $2F:begin
                   Index:=Size;
                 end;
             $51:begin
                   Tempo:=(longint(Data^[Index+0]) shl 16
                          +word(Data^[Index+1]) shl 8
                          +Data^[Index+2]);
  {For every quarternote, we have TicksPerQNote ticks}
                   Tempo:=Round(Tempo*MidMul);
                   MidiTempo:=Round((1000000 / Tempo) * Ticks);
                   KritWert:=FPS/MidiTempo;
                 end;
           end;
           Inc(Index,MetaSize);
         end;
    end;

    if Index>=Size then Timer:=-1 else
    begin
      newtimer:=0;
      Repeat
        b:=Data^[Index];
        Inc(Index);
        newtimer:=newtimer shl 7 + (b and $7F);
      Until b<128;
      timer:=timer+newtimer;
    end;
  end; { With Track^[T] }
end;

function playing:boolean;

var i:word;
    result:boolean;

begin
  result:=false;
  for i:=1 to trackcount do
  begin
    if tracks^[i].timer<>-1 then
      result:=true;
  end;
  playing:=result;
end;

{Spielt Midi im Hintergrund ab}
{Interrupt-Handler}
procedure MidMyInt08;{interrupt;}

var i:integer;

begin
  inc(MIDICounter);
  if not Playing then BEGIN
    for i:=1 to trackcount do
      tracks^[i]:=StartTracks^[i];
    {closemidi}MidiCounter:=0
  END else
  begin
    {Check all the channels for MIDI events}
    for i:=1 to TrackCount do
    begin
      {If it is time to handle an event, do so}
      if tracks^[i].timer>-1 then
        while (midicounter>tracks^[i].timer) and (tracks^[i].timer<>-1) do
          PlayTrack(i);
    end;
  end;

  {Check whether we need to call the original timer handler}
{  ClockTicks := ClockTicks + TickCounter;
  {Do so if required}
{  if ClockTicks > 65535 then
  begin
    dec (ClockTicks, 65536);
    asm pushf end;
    OrgInt08;
  end else port[$20]:=$20;}
end;


{Beendet das Midi-Abspielen}
Procedure CloseMidi;

var i:integer;

begin
  IF NOT MusicOn THEN Exit;
  MusOn:=false;
  if TrackCount>0 then
  begin
    For i:=1 to TrackCount do
    with Tracks^[i] do if Size>0 then FreeMem(Data,Size);

    FreeMem(Tracks,TrackCount*SizeOf(TTrack));
    FreeMem(StartTracks,TrackCount*SizeOf(TTrack));
  end;
  trackcount:=0;
end;

{Spielt Midi im Hintergrund ab}
procedure PlayMIDI(Addr:Pointer;MiMu:Real);

var i,K:integer;

begin
  InitMemLoad(Addr);
  MidMul:=MiMu;
  IF NOT MusicOn THEN Exit;
  {MIDI stoppen, falls was l�uft}
  FOR I:=0 TO 15 DO
    FOR K:=0 TO 127 DO
      NoteOff(I,K,0);
  FOR I:=0 TO MinChan-1 DO SetProgram(I,0);
  FOR I:=MinChan TO MaxChannels DO SFX[I].Busy:=FalsE;
  closemidi;
  ResetGM;
  ReadMidi;
  MIDICounter := 0;
  MusOn:=true;
end;

PROCEDURE AddSFX(Nr,Tone,Vol,Len,MaxA:LongInt);
VAR I,K,M:LongInt;
BEGIN
  IF NOT MusicOn THEN Exit;
  IF Pl[1].Energy=0 THEN Exit;
  K:=0;
  FOR I:=MinChan TO MaxChannels DO WITH SFX[I] DO IF (Busy)AND(Nr=No) THEN Inc(K);
IF K<MaxA THEN BEGIN
  I:=MinChan;
  WHILE (I<=MaxChannels)AND(SFX[I].Busy) DO Inc(I);
  IF I<=MaxChannels THEN WITH SFX[I] DO BEGIN
    Busy:=True;
    PlayTime:=Len;
    No:=Nr;
    Ton:=Tone;
    SetProgram(I,Nr);
    SetNoteOn(I,Tone,Vol);
  END;
END;
END;

PROCEDURE CalcSFX(Ticks:LongInt);
VAR I,K,M:LongInt;
BEGIN
  IF NOT MusicOn THEN Exit;
  FOR I:=MinChan TO MaxChannels DO WITH SFX[I] DO IF Busy THEN BEGIN
    IF PlayTime>Ticks THEN Dec(PlayTime,Ticks)
                      ELSE BEGIN
                        SetNoteOff(I,Ton,0);
                        Busy:=False;
                      END;
  END;
END;

begin
FOR I:=MinChan TO MaxChannels DO SFX[I].Busy:=False;
SFXAnz:=0;
end.