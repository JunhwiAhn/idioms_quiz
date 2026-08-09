// 카드 세트별 색 테마.
//
// 세트마다 배경·강조색만 바꾸고 레이아웃은 그대로 간다. 피드 그리드에서
// 시리즈가 색으로 구분되면서도 같은 계정이라는 게 보이도록, 채도와 명도는
// 전부 같은 수준으로 맞추고 색상(hue)만 돌린다.
//
// ink / muted / card 는 모든 테마가 공유한다. 글자색까지 흔들면 시리즈가
// 흩어져 보인다.

const SHARED = {
  ink: '#2E2018',
  muted: '#8A7566',
  card: '#FFFFFF',
};

/** accent 를 중심으로 배경(bg)·연한 배경(accentSoft)·구분선(line)을 짝지어 둔다. */
export const THEMES = {
  // 여행 (1편, 발행 완료) — 앱과 같은 테라코타
  travel: { accent: '#C44720', bg: '#FFFBF2', accentSoft: '#F6E2D6', line: '#EADCCB' },
  // 식당·카페 — 올리브
  restaurant: { accent: '#566B22', bg: '#FAFCF2', accentSoft: '#E5EDD2', line: '#DCE6C8' },
  // 쇼핑·계산 — 라즈베리
  shopping: { accent: '#B03A67', bg: '#FFF7FA', accentSoft: '#F7DCE7', line: '#EFD2DE' },
  // 교통·길찾기 — 틸블루
  transport: { accent: '#1B6F87', bg: '#F3FAFC', accentSoft: '#D6EAF1', line: '#C9E1EA' },
  // 호텔 — 플럼
  hotel: { accent: '#6E4A96', bg: '#FAF7FF', accentSoft: '#E8DEF6', line: '#DED2F0' },
  // 영어인 줄 알았는데 — 머스터드
  falseFriends: { accent: '#A87516', bg: '#FFFCF2', accentSoft: '#F5E6C4', line: '#EDDCB6' },
  // 이미 아는 스페인어 — 에메랄드
  known: { accent: '#17795E', bg: '#F4FBF8', accentSoft: '#D5EDE3', line: '#C6E4D8' },
  // 숫자·요일·시간 — 인디고
  numbers: { accent: '#3A55A0', bg: '#F5F8FD', accentSoft: '#DCE4F5', line: '#CED9EF' },
  // 발음 규칙 — 크림슨
  pronunciation: { accent: '#A82C3E', bg: '#FFF6F7', accentSoft: '#F7D9DD', line: '#EFCBD1' },
  // A1 필수 동사 — 딥 오렌지브라운
  verbs: { accent: '#8A4B12', bg: '#FFFAF3', accentSoft: '#F3E0CB', line: '#E8D3BA' },
  // 자기소개·대화 (영어판 전용) — 마젠타
  smalltalk: { accent: '#8E3A8E', bg: '#FDF6FD', accentSoft: '#F0DCF0', line: '#E5CCE5' },
};

export function theme(name) {
  const found = THEMES[name];
  if (!found) throw new Error(`"${name}" 테마가 없습니다. themes.js 를 확인하세요.`);
  return { ...SHARED, ...found };
}
