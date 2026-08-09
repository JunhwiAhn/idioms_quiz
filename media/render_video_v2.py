from pathlib import Path
import subprocess
import imageio_ffmpeg

ROOT = Path(__file__).resolve().parent
FFMPEG = imageio_ffmpeg.get_ffmpeg_exe()
BACKGROUND = ROOT / "neon_quiz_background_v2.png"
AUDIO = ROOT / "kpop_spanish_quiz_tts_v2.wav"
OUTPUT = ROOT / "kpop_spanish_quiz_layout_v2.mp4"

filters = (
    "[0:v]scale=1080:1920,setsar=1,"
    "zoompan=z='1.0+0.012*sin(on/45)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':"
    "d=1:s=1080x1920:fps=30,"
    "ass=quiz_v2.ass[v]"
)

cmd = [
    FFMPEG, "-y", "-loop", "1", "-i", str(BACKGROUND), "-i", str(AUDIO),
    "-filter_complex", filters, "-map", "[v]", "-map", "1:a",
    "-t", "30", "-c:v", "libx264", "-preset", "medium", "-crf", "18",
    "-pix_fmt", "yuv420p", "-r", "30", "-c:a", "aac", "-b:a", "192k",
    "-af", "loudnorm=I=-14:TP=-1.5:LRA=7,apad=pad_dur=30",
    "-movflags", "+faststart", str(OUTPUT)
]
subprocess.run(cmd, check=True, cwd=ROOT)
print(OUTPUT)
