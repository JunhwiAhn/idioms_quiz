from pathlib import Path
import subprocess
import imageio_ffmpeg

ROOT = Path(__file__).resolve().parent
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
AUDIO = ROOT / "kpop_spanish_quiz_tts.wav"
SUBS = ROOT / "quiz.ass"
OUTPUT = ROOT / "kpop_spanish_quiz_copyright_safe.mp4"

filter_graph = (
    "color=c=#070A18:s=1080x1920:d=29.5:r=30,"
    "drawbox=x='mod(t*90,1380)-300':y=250:w=300:h=1400:color=#7B2CFF@0.16:t=fill,"
    "drawbox=x='1080-mod(t*70,1320)':y=50:w=240:h=1600:color=#00F5FF@0.12:t=fill,"
    "drawbox=x=0:y='mod(t*110,2200)-280':w=1080:h=170:color=#D8FF3E@0.06:t=fill,"
    "noise=alls=5:allf=t+u,"
    "vignette=PI/4,"
    "ass=quiz.ass"
)

cmd = [
    FFMPEG, "-y",
    "-f", "lavfi", "-i", filter_graph,
    "-i", str(AUDIO),
    "-t", "29.5",
    "-c:v", "libx264", "-preset", "medium", "-crf", "18",
    "-pix_fmt", "yuv420p", "-r", "30",
    "-c:a", "aac", "-b:a", "192k",
    "-af", "loudnorm=I=-14:TP=-1.5:LRA=7,apad=pad_dur=29.5",
    "-movflags", "+faststart",
    str(OUTPUT),
]

subprocess.run(cmd, check=True, cwd=ROOT)
print(OUTPUT)
