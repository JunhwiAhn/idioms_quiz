#!/usr/bin/env bash
set -euo pipefail

# ep03-bano — 총 64.5 크레딧
#
# 각 단계는 결과 URL만 출력한다. 다음 단계로 넘어가기 전에 그 URL을 지정된
# 경로로 내려받아야 한다. 자동화하지 않은 건 매 단계에서 눈으로 보고
# 다시 뽑을지 정해야 하기 때문이다.

# 0단계: 캐릭터 시트 (0.5 cr). 마음에 들 때까지 여기서만 다시 뽑는다.
#         결과를 charsheet.png 로 저장한다. 시리즈 전체가 이 한 장을 재사용한다.
higgsfield generate create gpt_image_2 --aspect_ratio 16:9 --wait --prompt "$(cat prompts/00-charsheet.txt)"

# 1단계: 키프레임 8장. 캐릭터 시트를 레퍼런스로 물린다. → frames/NN.png

# --- SHOT 1 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/01.txt)"

# --- SHOT 2 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/02.txt)"

# --- SHOT 3 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/03.txt)"

# --- SHOT 4 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/04.txt)"

# --- SHOT 5 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/05.txt)"

# --- SHOT 6 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/06.txt)"

# --- SHOT 7 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --image charsheet.png --wait --prompt "$(cat prompts/07.txt)"

# --- SHOT 8 키프레임 (0.5 cr) ---
higgsfield generate create gpt_image_2 --aspect_ratio 9:16 --wait --prompt "$(cat prompts/08.txt)"

# 2단계: 키프레임 → 영상. frames/NN.png 가 다 있어야 한다.

# --- SHOT 1 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/01.png \
  --prompt "Slow push in toward HIJO. He shifts his weight twice. HIJA turns her head once. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 2 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/02.png \
  --prompt "Static shot. HIJO tugs the arm once. MADRE raises her open hand and points. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 3 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/03.png \
  --prompt "Static shot. MADRE's mouth opens clearly on each word. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 4 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/04.png \
  --prompt "Static shot. MADRE draws one small circle in the air. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 5 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/05.png \
  --prompt "Slight push in. HIJO straightens up and his mouth opens wide. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 6 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/06.png \
  --prompt "Slight push in. The attendant extends her arm to point down the corridor. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 7 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/07.png \
  --prompt "Static shot. Nobody moves except HIJA slowly turning her head toward the sandal. Background static." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait

# --- SHOT 8 영상 (7.5 cr) ---
higgsfield generate create kling3_0_turbo \
  --start-image frames/08.png \
  --prompt "Static shot. The arrow sign sways almost imperceptibly. Nothing else moves." \
  --duration 5 --resolution 1080p --aspect_ratio 9:16 --wait
