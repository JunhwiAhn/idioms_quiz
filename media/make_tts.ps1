$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Speech

$outputPath = Join-Path $PSScriptRoot 'kpop_spanish_quiz_tts.wav'
$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer
$synth.SelectVoice('Microsoft Zira Desktop')
$synth.SetOutputToWaveFile($outputPath)

$ssml = @'
<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xml:lang="en-US">
  <voice name="Microsoft Zira Desktop">
    <prosody rate="+8%" pitch="+2%">
      Listen carefully. <break time="350ms"/>
      What does this Spanish sentence mean? <break time="500ms"/>
      Es hora de una nueva estrategia. <break time="900ms"/>
      Three. <break time="450ms"/> Two. <break time="450ms"/> One. <break time="500ms"/>
      The answer is: It's time for a new strategy. <break time="450ms"/>
      Es hora de means, it's time to. <break time="250ms"/>
      Nueva means new. <break time="250ms"/>
      Estrategia means strategy. <break time="550ms"/>
      Now say it with me. <break time="300ms"/>
      Es hora de una nueva estrategia.
    </prosody>
  </voice>
</speak>
'@

try {
  $synth.SpeakSsml($ssml)
} finally {
  $synth.Dispose()
}

Write-Output $outputPath
