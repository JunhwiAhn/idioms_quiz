// One original teaching note per episode, written for that day's exact words.
//
// This is the part of each video that is not generated from a template: a
// pattern a beginner would otherwise have to be told, tied to the five words
// that just appeared. It is what makes DAY 7 a different lesson from DAY 8
// rather than the same lesson with the nouns swapped.
//
// Keys are day numbers. `headline` is the short label on screen, `body` is the
// note itself (also appended to the video description).

export const TIPS = {
  1: {
    ko: { headline: '동사에서 명사가 나옵니다', body: 'comer(먹다)에서 comida(음식)가, cenar(저녁을 먹다)에서 cena(저녁 식사)가 나왔습니다. 동사를 알면 명사가 따라옵니다.' },
    en: { headline: 'Verbs turn into nouns', body: 'comer (to eat) gives comida (food); cenar (to have dinner) gives cena (dinner). Learn the verb and the noun comes free.' },
    ja: { headline: '動詞から名詞ができます', body: 'comer(食べる)から comida(食べ物)、cenar(夕食をとる)から cena(夕食)。動詞を覚えると名詞もついてきます。' },
  },
  2: {
    ko: { headline: 'agua는 예외입니다', body: 'agua는 여성 명사지만 el agua라고 씁니다. a- 소리가 강세를 받으면 발음 때문에 el을 쓰거든요. 복수는 다시 las aguas입니다.' },
    en: { headline: 'agua is an exception', body: 'agua is feminine but takes el — a stressed a- sound at the start swaps la for el. In the plural it goes back to las aguas.' },
    ja: { headline: 'agua は例外です', body: 'agua は女性名詞ですが el agua と言います。強勢のある a- で始まる語は発音の都合で el を使います。複数形は las aguas に戻ります。' },
  },
  3: {
    ko: { headline: '-a로 끝나면 대개 여성', body: 'casa, silla, puerta, ventana 모두 -a로 끝나는 여성 명사라 la를 씁니다. baño만 -o로 끝나는 남성 명사, el baño입니다.' },
    en: { headline: 'Words ending in -a are usually feminine', body: 'casa, silla, puerta, ventana all end in -a and take la. Only baño ends in -o, so it is el baño.' },
    ja: { headline: '-a で終わる語はたいてい女性', body: 'casa・silla・puerta・ventana はどれも -a で終わる女性名詞で la を使います。baño だけ -o 終わりの男性名詞で el baño です。' },
  },
  4: {
    ko: { headline: 'mañana는 뜻이 두 개', body: 'la mañana는 "아침", mañana는 "내일"입니다. 관사가 붙으면 시간대, 안 붙으면 날짜라고 기억하세요.' },
    en: { headline: 'mañana means two things', body: 'la mañana is "the morning"; mañana on its own is "tomorrow". With an article it is a time of day, without one it is a date.' },
    ja: { headline: 'mañana は意味が二つ', body: 'la mañana は「朝」、mañana だけなら「明日」です。冠詞が付けば時間帯、付かなければ日付と覚えましょう。' },
  },
  5: {
    ko: { headline: '동사는 세 종류로 끝납니다', body: 'hablar, cambiar, necesitar는 -ar, vivir는 -ir, tener는 -er입니다. 스페인어 동사는 이 셋 중 하나로 끝나고, 변화 방식도 여기서 갈립니다.' },
    en: { headline: 'Verbs end three ways', body: 'hablar, cambiar and necesitar end in -ar, vivir in -ir, tener in -er. Every Spanish verb is one of these three, and that ending decides how it conjugates.' },
    ja: { headline: '動詞の語尾は三種類', body: 'hablar・cambiar・necesitar は -ar、vivir は -ir、tener は -er。スペイン語の動詞はこの三つのどれかで終わり、活用の型もそこで決まります。' },
  },
  6: {
    ko: { headline: 'ser와 estar의 차이', body: '둘 다 "이다"지만, ser는 변하지 않는 성질(Soy coreano), estar는 지금의 상태나 위치(Estoy en casa)에 씁니다.' },
    en: { headline: 'ser vs estar', body: 'Both mean "to be". ser is for what does not change (Soy coreano); estar is for a current state or location (Estoy en casa).' },
    ja: { headline: 'ser と estar の違い', body: 'どちらも「〜である」ですが、ser は変わらない性質(Soy coreano)、estar は今の状態や場所(Estoy en casa)に使います。' },
  },
  7: {
    ko: { headline: '형용사도 성·수를 따라갑니다', body: 'pequeño는 남성, pequeña는 여성입니다. viejo/vieja도 마찬가지. grande와 joven은 남녀 구분 없이 그대로 씁니다.' },
    en: { headline: 'Adjectives agree too', body: 'pequeño is masculine, pequeña feminine — same for viejo/vieja. grande and joven stay the same for both genders.' },
    ja: { headline: '形容詞も性・数に合わせます', body: 'pequeño は男性形、pequeña は女性形。viejo/vieja も同じです。grande と joven は性別で変わりません。' },
  },
  8: {
    ko: { headline: '-ía로 끝나는 가게 이름', body: 'farmacia처럼 -ía로 끝나면 대개 파는 곳입니다. pan(빵) → panadería, carne(고기) → carnicería. 규칙이 보이시죠?' },
    en: { headline: 'Shops end in -ía', body: 'Like farmacia, a place that sells something usually ends in -ía: pan (bread) → panadería, carne (meat) → carnicería.' },
    ja: { headline: '-ía で終わるお店の名前', body: 'farmacia のように -ía で終わる語はたいてい売る場所です。pan(パン)→ panadería、carne(肉)→ carnicería。' },
  },
  9: {
    ko: { headline: 'ciudad와 pueblo', body: 'ciudad는 도시, pueblo는 작은 마을입니다. pueblo에는 "국민, 민중"이라는 뜻도 있어서 문맥으로 구분합니다.' },
    en: { headline: 'ciudad vs pueblo', body: 'ciudad is a city, pueblo a small town. pueblo also means "the people" of a country, so context decides.' },
    ja: { headline: 'ciudad と pueblo', body: 'ciudad は都市、pueblo は小さな町。pueblo には「国民・民衆」の意味もあるので文脈で判断します。' },
  },
  10: {
    ko: { headline: 'ir는 가장 불규칙한 동사', body: 'ir(가다)는 원형과 활용형이 전혀 닮지 않았습니다. voy, vas, va… 통째로 외우는 편이 빠릅니다.' },
    en: { headline: 'ir is the most irregular verb', body: 'ir (to go) looks nothing like its conjugations: voy, vas, va… Memorising the set whole is faster than looking for a rule.' },
    ja: { headline: 'ir は最も不規則な動詞', body: 'ir(行く)は原形と活用形が全く似ていません。voy, vas, va… まとめて覚えるほうが早いです。' },
  },
  11: {
    ko: { headline: '악센트 부호는 강세 표시', body: 'avión, autobús의 부호는 그 자리에 강세를 준다는 뜻입니다. 아비ON, 아우토BUS처럼 뒤를 세게 읽어보세요.' },
    en: { headline: 'The accent mark shows the stress', body: 'In avión and autobús the mark tells you where to push: a-viÓN, au-to-BÚS. It is not a different vowel sound.' },
    ja: { headline: 'アクセント記号は強勢の位置', body: 'avión や autobús の記号は、そこを強く読むという印です。a-viÓN、au-to-BÚS のように後ろを強く読んでみましょう。' },
  },
  12: {
    ko: { headline: 'll은 "ㅇ" 소리에 가깝습니다', body: 'maleta는 그대로 읽지만, ll이 들어간 단어는 다릅니다. calle는 "칼레"가 아니라 "카예"에 가깝게 발음됩니다.' },
    en: { headline: 'll is not an L sound', body: 'In most of the Spanish-speaking world ll sounds like the y in "yes" — calle is closer to "ka-yeh" than "kal-leh".' },
    ja: { headline: 'll は「ヤ行」に近い音', body: 'スペイン語の ll は「ヤ行」に近い音になります。calle は「カレ」ではなく「カジェ」に近い発音です。' },
  },
  13: {
    ko: { headline: '물음표는 앞에도 붙습니다', body: '스페인어는 문장 앞에 ¿를 뒤집어 붙입니다. ¿Cuál es la respuesta? 처럼요. 읽기 전에 의문문인 걸 알려주는 장치입니다.' },
    en: { headline: 'Questions open with ¿', body: 'Spanish marks a question at both ends: ¿Cuál es la respuesta? The upside-down mark warns you before you start reading.' },
    ja: { headline: '疑問符は文頭にも付きます', body: 'スペイン語は文の初めに ¿ を逆さに付けます。¿Cuál es la respuesta? 読み始める前に疑問文だと分かる仕組みです。' },
  },
  14: {
    ko: { headline: 'aprender와 estudiar', body: 'estudiar는 공부하는 행위, aprender는 그 결과로 익히는 것입니다. Estudio español, y aprendo mucho.' },
    en: { headline: 'aprender vs estudiar', body: 'estudiar is the act of studying; aprender is what you end up learning. Estudio español, y aprendo mucho.' },
    ja: { headline: 'aprender と estudiar', body: 'estudiar は勉強するという行為、aprender はその結果として身につくこと。Estudio español, y aprendo mucho.' },
  },
  15: {
    ko: { headline: 'trabajo는 명사이자 동사', body: 'el trabajo는 "일", trabajo는 trabajar의 1인칭 활용 "나는 일한다"입니다. 형태가 같아 관사로 구분합니다.' },
    en: { headline: 'trabajo is both noun and verb', body: 'el trabajo is "the job"; trabajo on its own is "I work", from trabajar. The article tells you which one it is.' },
    ja: { headline: 'trabajo は名詞でも動詞', body: 'el trabajo は「仕事」、trabajo だけなら trabajar の一人称「私は働く」です。冠詞の有無で見分けます。' },
  },
  16: {
    ko: { headline: 'j는 목에서 나는 소리', body: 'jefe의 j는 "ㅈ"이 아니라 "ㅎ"에 가깝습니다. "헤페"처럼 목 안쪽에서 긁듯이 발음합니다.' },
    en: { headline: 'j comes from the throat', body: 'The j in jefe is not an English j — it is a raspy h from the back of the throat: "HEH-feh".' },
    ja: { headline: 'j はのどの奥で出す音', body: 'jefe の j は「ジ」ではなく、のどの奥でこするような「ハ行」の音です。「ヘフェ」に近く発音します。' },
  },
  17: {
    ko: { headline: '형용사는 보통 명사 뒤에', body: '스페인어는 una flor bonita처럼 형용사를 명사 뒤에 둡니다. 한국어와 순서가 반대라 처음엔 어색하게 느껴집니다.' },
    en: { headline: 'Adjectives follow the noun', body: 'Spanish says una flor bonita — a flower pretty. The adjective normally comes after the noun, not before it.' },
    ja: { headline: '形容詞は名詞の後ろ', body: 'スペイン語は una flor bonita のように形容詞を名詞の後ろに置きます。日本語とは順序が逆です。' },
  },
  18: {
    ko: { headline: '비교는 más ... que', body: 'más와 menos에 que를 붙이면 비교가 됩니다. Es más rápido que el tren. (기차보다 빠릅니다.)' },
    en: { headline: 'Comparisons use más ... que', body: 'Add que to más or menos and you have a comparison: Es más rápido que el tren — faster than the train.' },
    ja: { headline: '比較は más ... que', body: 'más や menos に que を付けると比較になります。Es más rápido que el tren.(電車より速いです。)' },
  },
  19: {
    ko: { headline: 'aunque 뒤에는 두 가지', body: 'aunque는 사실을 말할 땐 직설법, 가정할 땐 접속법을 씁니다. 지금은 "비록 ~지만" 정도로만 알아두면 충분합니다.' },
    en: { headline: 'aunque takes two moods', body: 'aunque uses the indicative for facts and the subjunctive for hypotheticals. For now, "even though" is enough.' },
    ja: { headline: 'aunque の後ろは二通り', body: 'aunque は事実を述べるときは直説法、仮定のときは接続法を使います。今は「〜だけれども」と覚えれば十分です。' },
  },
  20: {
    ko: { headline: 'gustar는 주어가 뒤집힙니다', body: 'Me gusta el café는 "커피가 나에게 좋게 느껴진다"는 구조입니다. 좋아하는 사람이 아니라 대상이 주어입니다.' },
    en: { headline: 'gustar flips the subject', body: 'Me gusta el café literally means "coffee pleases me". The thing you like is the subject, not you.' },
    ja: { headline: 'gustar は主語が逆', body: 'Me gusta el café は「コーヒーが私に好ましい」という構造です。好きな人ではなく対象が主語になります。' },
  },
};

export function tipFor(day, lang) {
  const tip = TIPS[day]?.[lang];
  if (!tip) throw new Error(`No ${lang} tip written for day ${day}`);
  return tip;
}
