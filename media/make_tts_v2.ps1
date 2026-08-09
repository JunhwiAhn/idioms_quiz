$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech

$outputPath = Join-Path $PSScriptRoot 'kpop_spanish_quiz_tts_v2.wav'
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SelectVoice('Microsoft Zira Desktop')
$synth.SetOutputToWaveFile($outputPath)
$ssml = @'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
  <voice name="Microsoft Zira Desktop">
    <prosody rate="+8%" pitch="+2%">
      Listen closely. What did they say? <break time="4200ms"/>
      Choose the correct meaning. <break time="900ms"/>
      Three. <break time="450ms"/> Two. <break time="450ms"/> One. <break time="450ms"/>
      The answer is A. It's time for a new strategy. <break time="350ms"/>
      Es hora de means, it's time to. <break time="200ms"/>
      Nueva means new. <break time="200ms"/>
      Estrategia means strategy. <break time="450ms"/>
      Now say it with me. Es hora de una nueva estrategia.
    </prosody>
  </voice>
</speak>
'@

try { $synth.SpeakSsml($ssml) } finally { $synth.Dispose() }
Write-Output $outputPath
