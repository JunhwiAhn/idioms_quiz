const fs = require('fs');

const path = 'assets/data/idioms.json';
const entries = JSON.parse(fs.readFileSync(path, 'utf8'));

const natural = {
  montana: ['La montaña está cubierta de nieve.', '산이 눈으로 덮여 있다.', 'The mountain is covered with snow.', '山は雪で覆われています。', 'La ____ está cubierta de nieve.'],
};

const updates = {
  'montaña': ['La montaña está cubierta de nieve.', '산이 눈으로 덮여 있다.', 'The mountain is covered with snow.', '山は雪で覆われています。', 'La ____ está cubierta de nieve.'],
  'país': ['España es un país con mucha historia.', '스페인은 역사가 많은 나라다.', 'Spain is a country with a lot of history.', 'スペインは歴史の多い国です。', 'España es un ____ con mucha historia.'],
  'idioma': ['Aprendo un idioma nuevo en la universidad.', '나는 대학교에서 새로운 언어를 배운다.', 'I learn a new language at the university.', '大学で新しい言語を学びます。', 'Aprendo un ____ nuevo en la universidad.'],
  'palabra': ['No entiendo esta palabra en el texto.', '나는 본문에 있는 이 단어를 이해하지 못한다.', 'I do not understand this word in the text.', '本文のこの単語が分かりません。', 'No entiendo esta ____ en el texto.'],
  'pregunta': ['El profesor responde a mi pregunta.', '선생님이 내 질문에 답한다.', 'The teacher answers my question.', '先生が私の質問に答えます。', 'El profesor responde a mi ____.'],
  'respuesta': ['Tu respuesta es clara y correcta.', '네 대답은 명확하고 맞다.', 'Your answer is clear and correct.', 'あなたの答えは明確で正しいです。', 'Tu ____ es clara y correcta.'],
  'problema': ['Tenemos un problema con la reserva.', '우리는 예약에 문제가 있다.', 'We have a problem with the reservation.', '予約に問題があります。', 'Tenemos un ____ con la reserva.'],
  'idea': ['Tengo una idea para el proyecto.', '나는 프로젝트에 대한 생각이 하나 있다.', 'I have an idea for the project.', 'プロジェクトのためのアイデアがあります。', 'Tengo una ____ para el proyecto.'],
  'vida': ['La vida en esta ciudad es tranquila.', '이 도시에서의 삶은 평온하다.', 'Life in this city is quiet.', 'この町での生活は穏やかです。', 'La ____ en esta ciudad es tranquila.'],
  'mundo': ['Quiero viajar por el mundo.', '나는 세계를 여행하고 싶다.', 'I want to travel around the world.', '世界を旅したいです。', 'Quiero viajar por el ____.'],
  'salud': ['Dormir bien es importante para la salud.', '잠을 잘 자는 것은 건강에 중요하다.', 'Sleeping well is important for health.', 'よく眠ることは健康に大切です。', 'Dormir bien es importante para la ____.'],
  'cuerpo': ['El cuerpo necesita agua cada día.', '몸은 매일 물이 필요하다.', 'The body needs water every day.', '体は毎日水を必要とします。', 'El ____ necesita agua cada día.'],
  'cabeza': ['Me duele la cabeza desde la mañana.', '아침부터 머리가 아프다.', 'My head has hurt since morning.', '朝から頭が痛いです。', 'Me duele la ____ desde la mañana.'],
  'mano': ['Levanta la mano para preguntar.', '질문하려면 손을 들어라.', 'Raise your hand to ask a question.', '質問するために手を上げます。', 'Levanta la ____ para preguntar.'],
  'ojo': ['Tiene un ojo rojo por el polvo.', '그는 먼지 때문에 눈이 빨갛다.', 'He has a red eye because of dust.', 'ほこりで目が赤くなっています。', 'Tiene un ____ rojo por el polvo.'],
  'ropa': ['Lavo la ropa los domingos.', '나는 일요일마다 옷을 빤다.', 'I wash clothes on Sundays.', '日曜日に服を洗います。', 'Lavo la ____ los domingos.'],
  'zapato': ['Este zapato me queda pequeño.', '이 신발은 내게 작다.', 'This shoe is too small for me.', 'この靴は私には小さいです。', 'Este ____ me queda pequeño.'],
  'color': ['Me gusta el color azul.', '나는 파란색을 좋아한다.', 'I like the color blue.', '青い色が好きです。', 'Me gusta el ____ azul.'],
  'música': ['Escucho música mientras trabajo.', '나는 일하면서 음악을 듣는다.', 'I listen to music while I work.', '仕事をしながら音楽を聞きます。', 'Escucho ____ mientras trabajo.'],
  'película': ['Vemos una película esta noche.', '우리는 오늘 밤 영화를 본다.', 'We watch a movie tonight.', '今夜映画を見ます。', 'Vemos una ____ esta noche.'],
  'deporte': ['El deporte ayuda a mantener la salud.', '스포츠는 건강을 유지하는 데 도움이 된다.', 'Sports help maintain health.', 'スポーツは健康維持に役立ちます。', 'El ____ ayuda a mantener la salud.'],
  'partido': ['El partido empieza a las seis.', '경기는 여섯 시에 시작한다.', 'The match starts at six.', '試合は6時に始まります。', 'El ____ empieza a las seis.'],
  'fiesta': ['La fiesta termina tarde.', '파티는 늦게 끝난다.', 'The party ends late.', 'パーティーは遅く終わります。', 'La ____ termina tarde.'],
  'regalo': ['Compro un regalo para mi madre.', '나는 어머니를 위한 선물을 산다.', 'I buy a gift for my mother.', '母へのプレゼントを買います。', 'Compro un ____ para mi madre.'],
  'correo': ['Recibo el correo por la tarde.', '나는 오후에 우편을 받는다.', 'I receive the mail in the afternoon.', '午後に郵便を受け取ります。', 'Recibo el ____ por la tarde.'],
  'mensaje': ['Te envío un mensaje después.', '나중에 너에게 메시지를 보낼게.', 'I will send you a message later.', '後でメッセージを送ります。', 'Te envío un ____ después.'],
  'noticia': ['La noticia aparece en el periódico.', '그 뉴스는 신문에 나온다.', 'The news appears in the newspaper.', 'そのニュースは新聞に載っています。', 'La ____ aparece en el periódico.'],
  'reunión': ['La reunión empieza a las diez.', '회의는 열 시에 시작한다.', 'The meeting starts at ten.', '会議は10時に始まります。', 'La ____ empieza a las diez.'],
  'empresa': ['Mi hermana trabaja en una empresa grande.', '내 여동생은 큰 회사에서 일한다.', 'My sister works at a big company.', '妹は大きな会社で働いています。', 'Mi hermana trabaja en una ____ grande.'],
  'jefe': ['El jefe revisa el proyecto.', '상사가 프로젝트를 검토한다.', 'The boss reviews the project.', '上司がプロジェクトを確認します。', 'El ____ revisa el proyecto.'],
  'cliente': ['El cliente espera una respuesta rápida.', '고객은 빠른 답변을 기다린다.', 'The client expects a quick answer.', '顧客は早い返事を待っています。', 'El ____ espera una respuesta rápida.'],
  'proyecto': ['El proyecto necesita más tiempo.', '그 프로젝트는 시간이 더 필요하다.', 'The project needs more time.', 'そのプロジェクトにはもっと時間が必要です。', 'El ____ necesita más tiempo.'],
  'servicio': ['El servicio del hotel es excelente.', '그 호텔의 서비스는 훌륭하다.', 'The hotel service is excellent.', 'ホテルのサービスは素晴らしいです。', 'El ____ del hotel es excelente.'],
  'oficina': ['La oficina está en el centro.', '사무실은 중심가에 있다.', 'The office is downtown.', 'オフィスは中心部にあります。', 'La ____ está en el centro.'],
  'universidad': ['Estudio historia en la universidad.', '나는 대학교에서 역사를 공부한다.', 'I study history at the university.', '大学で歴史を勉強しています。', 'Estudio historia en la ____.'],
  'clase': ['La clase de español empieza pronto.', '스페인어 수업이 곧 시작한다.', 'The Spanish class starts soon.', 'スペイン語の授業がもうすぐ始まります。', 'La ____ de español empieza pronto.'],
  'examen': ['Mañana tengo un examen de español.', '내일 스페인어 시험이 있다.', 'Tomorrow I have a Spanish exam.', '明日スペイン語の試験があります。', 'Mañana tengo un ____ de español.'],
  'nota': ['Necesito una buena nota para aprobar.', '합격하려면 좋은 성적이 필요하다.', 'I need a good grade to pass.', '合格するには良い成績が必要です。', 'Necesito una buena ____ para aprobar.'],
  'historia': ['Me interesa la historia de México.', '나는 멕시코 역사에 관심이 있다.', 'I am interested in Mexican history.', 'メキシコの歴史に興味があります。', 'Me interesa la ____ de México.'],
  'cultura': ['La cultura local es muy rica.', '지역 문화는 매우 풍부하다.', 'The local culture is very rich.', '地域の文化はとても豊かです。', 'La ____ local es muy rica.'],
  'arte': ['El museo tiene arte moderno.', '그 박물관에는 현대 예술이 있다.', 'The museum has modern art.', 'その美術館には現代アートがあります。', 'El museo tiene ____ moderno.'],
  'naturaleza': ['Me gusta caminar en la naturaleza.', '나는 자연 속에서 걷는 것을 좋아한다.', 'I like walking in nature.', '自然の中を歩くのが好きです。', 'Me gusta caminar en la ____.'],
  'animal': ['El animal duerme bajo el árbol.', '그 동물은 나무 아래에서 잔다.', 'The animal sleeps under the tree.', 'その動物は木の下で寝ています。', 'El ____ duerme bajo el árbol.'],
  'flor': ['Esta flor huele muy bien.', '이 꽃은 향기가 좋다.', 'This flower smells very nice.', 'この花はとても良い香りがします。', 'Esta ____ huele muy bien.'],
  'árbol': ['El árbol da sombra en verano.', '그 나무는 여름에 그늘을 만든다.', 'The tree gives shade in summer.', 'その木は夏に日陰を作ります。', 'El ____ da sombra en verano.'],
  'sol': ['El sol sale temprano.', '태양은 일찍 뜬다.', 'The sun rises early.', '太陽は早く昇ります。', 'El ____ sale temprano.'],
  'lluvia': ['La lluvia moja las calles.', '비가 거리를 적신다.', 'The rain wets the streets.', '雨が通りを濡らします。', 'La ____ moja las calles.'],
  'viento': ['El viento mueve las hojas.', '바람이 나뭇잎을 움직인다.', 'The wind moves the leaves.', '風が葉を動かします。', 'El ____ mueve las hojas.'],
  'frío': ['Hace frío por la mañana.', '아침에는 춥다.', 'It is cold in the morning.', '朝は寒いです。', 'Hace ____ por la mañana.'],
  'calor': ['Hace calor en la cocina.', '부엌은 덥다.', 'It is hot in the kitchen.', '台所は暑いです。', 'Hace ____ en la cocina.'],
  'cocina': ['Preparo la cena en la cocina.', '나는 부엌에서 저녁을 준비한다.', 'I prepare dinner in the kitchen.', '台所で夕食を準備します。', 'Preparo la cena en la ____.'],
  'baño': ['El baño está al final del pasillo.', '욕실은 복도 끝에 있다.', 'The bathroom is at the end of the hallway.', '浴室は廊下の端にあります。', 'El ____ está al final del pasillo.'],
  'banco': ['Voy al banco para sacar dinero.', '나는 돈을 찾으러 은행에 간다.', 'I go to the bank to withdraw money.', 'お金を引き出しに銀行へ行きます。', 'Voy al ____ para sacar dinero.'],
  'farmacia': ['Compro medicina en la farmacia.', '나는 약국에서 약을 산다.', 'I buy medicine at the pharmacy.', '薬局で薬を買います。', 'Compro medicina en la ____.'],
  'hospital': ['El hospital está cerca de aquí.', '병원은 여기에서 가깝다.', 'The hospital is near here.', '病院はここから近いです。', 'El ____ está cerca de aquí.'],
  'policía': ['La policía ayuda al turista perdido.', '경찰은 길을 잃은 관광객을 돕는다.', 'The police help the lost tourist.', '警察は道に迷った観光客を助けます。', 'La ____ ayuda al turista perdido.'],
  'mapa': ['Necesito un mapa de la ciudad.', '나는 도시 지도가 필요하다.', 'I need a map of the city.', '街の地図が必要です。', 'Necesito un ____ de la ciudad.'],
  'dirección': ['Escribe tu dirección en este formulario.', '이 양식에 주소를 써라.', 'Write your address on this form.', 'この用紙に住所を書いてください。', 'Escribe tu ____ en este formulario.'],
  'pasaporte': ['Necesito mi pasaporte para viajar.', '여행하려면 여권이 필요하다.', 'I need my passport to travel.', '旅行にはパスポートが必要です。', 'Necesito mi ____ para viajar.'],
  'maleta': ['Mi maleta pesa demasiado.', '내 여행가방은 너무 무겁다.', 'My suitcase is too heavy.', '私のスーツケースは重すぎます。', 'Mi ____ pesa demasiado.'],

  'ser': ['Quiero ser médico en el futuro.', '나는 미래에 의사가 되고 싶다.', 'I want to be a doctor in the future.', '将来医者になりたいです。', 'Quiero ____ médico en el futuro.'],
  'estar': ['Voy a estar en casa esta tarde.', '나는 오늘 오후에 집에 있을 것이다.', 'I am going to be at home this afternoon.', '今日の午後は家にいます。', 'Voy a ____ en casa esta tarde.'],
  'tener': ['Necesito tener el pasaporte listo.', '여권을 준비해 두어야 한다.', 'I need to have the passport ready.', 'パスポートを準備しておく必要があります。', 'Necesito ____ el pasaporte listo.'],
  'hacer': ['Voy a hacer la cena esta noche.', '나는 오늘 밤 저녁을 만들 것이다.', 'I am going to make dinner tonight.', '今夜夕食を作ります。', 'Voy a ____ la cena esta noche.'],
  'ir': ['Quiero ir al mercado temprano.', '나는 일찍 시장에 가고 싶다.', 'I want to go to the market early.', '早く市場へ行きたいです。', 'Quiero ____ al mercado temprano.'],
  'venir': ['Puedes venir a mi casa mañana.', '너는 내일 우리 집에 와도 된다.', 'You can come to my house tomorrow.', '明日私の家に来てもいいです。', 'Puedes ____ a mi casa mañana.'],
  'comer': ['Vamos a comer paella en Valencia.', '우리는 발렌시아에서 파에야를 먹을 것이다.', 'We are going to eat paella in Valencia.', 'バレンシアでパエリアを食べます。', 'Vamos a ____ paella en Valencia.'],
  'beber': ['Prefiero beber agua con la comida.', '나는 식사와 함께 물을 마시는 것을 선호한다.', 'I prefer to drink water with the meal.', '食事には水を飲むほうが好きです。', 'Prefiero ____ agua con la comida.'],
  'vivir': ['Quiero vivir cerca del mar.', '나는 바다 근처에 살고 싶다.', 'I want to live near the sea.', '海の近くに住みたいです。', 'Quiero ____ cerca del mar.'],
  'hablar': ['Necesito hablar con el profesor.', '나는 선생님과 말해야 한다.', 'I need to speak with the teacher.', '先生と話す必要があります。', 'Necesito ____ con el profesor.'],
  'escuchar': ['Me gusta escuchar música tranquila.', '나는 잔잔한 음악을 듣는 것을 좋아한다.', 'I like listening to calm music.', '静かな音楽を聞くのが好きです。', 'Me gusta ____ música tranquila.'],
  'leer': ['Voy a leer este libro hoy.', '나는 오늘 이 책을 읽을 것이다.', 'I am going to read this book today.', '今日この本を読みます。', 'Voy a ____ este libro hoy.'],
  'escribir': ['Quiero escribir un mensaje corto.', '나는 짧은 메시지를 쓰고 싶다.', 'I want to write a short message.', '短いメッセージを書きたいです。', 'Quiero ____ un mensaje corto.'],
  'estudiar': ['Tengo que estudiar para el examen.', '나는 시험을 위해 공부해야 한다.', 'I have to study for the exam.', '試験のために勉強しなければなりません。', 'Tengo que ____ para el examen.'],
  'trabajar': ['Mi padre va a trabajar temprano.', '아버지는 일찍 일하러 간다.', 'My father goes to work early.', '父は早く仕事に行きます。', 'Mi padre va a ____ temprano.'],
  'comprar': ['Voy a comprar fruta en el mercado.', '나는 시장에서 과일을 살 것이다.', 'I am going to buy fruit at the market.', '市場で果物を買います。', 'Voy a ____ fruta en el mercado.'],
  'vender': ['La tienda quiere vender pan fresco.', '그 가게는 신선한 빵을 팔고 싶어 한다.', 'The shop wants to sell fresh bread.', 'その店は焼きたてのパンを売りたがっています。', 'La tienda quiere ____ pan fresco.'],
  'pagar': ['Tengo que pagar la cuenta.', '나는 계산서를 지불해야 한다.', 'I have to pay the bill.', '会計を払わなければなりません。', 'Tengo que ____ la cuenta.'],
  'abrir': ['Puedes abrir la ventana.', '창문을 열어도 된다.', 'You can open the window.', '窓を開けてもいいです。', 'Puedes ____ la ventana.'],
  'cerrar': ['Por favor, cierra la puerta.', '문을 닫아 주세요.', 'Please close the door.', 'ドアを閉めてください。', 'Por favor, ____ la puerta.'],
  'entrar': ['No podemos entrar sin billete.', '표 없이는 들어갈 수 없다.', 'We cannot enter without a ticket.', '切符なしでは入れません。', 'No podemos ____ sin billete.'],
  'salir': ['Quiero salir después de la clase.', '나는 수업 후에 나가고 싶다.', 'I want to leave after class.', '授業の後に出かけたいです。', 'Quiero ____ después de la clase.'],
  'llegar': ['Espero llegar antes de la reunión.', '나는 회의 전에 도착하기를 바란다.', 'I hope to arrive before the meeting.', '会議の前に到着したいです。', 'Espero ____ antes de la reunión.'],
  'saludar': ['Voy a saludar a los vecinos.', '나는 이웃들에게 인사할 것이다.', 'I am going to greet the neighbors.', '近所の人に挨拶します。', 'Voy a ____ a los vecinos.'],
  'llamar': ['Tengo que llamar al hospital.', '나는 병원에 전화해야 한다.', 'I have to call the hospital.', '病院に電話しなければなりません。', 'Tengo que ____ al hospital.'],
  'buscar': ['Voy a buscar la dirección en el mapa.', '나는 지도에서 주소를 찾을 것이다.', 'I am going to look for the address on the map.', '地図で住所を探します。', 'Voy a ____ la dirección en el mapa.'],
  'encontrar': ['Espero encontrar un hotel barato.', '나는 저렴한 호텔을 찾기를 바란다.', 'I hope to find a cheap hotel.', '安いホテルを見つけたいです。', 'Espero ____ un hotel barato.'],
  'pensar': ['Necesito pensar antes de responder.', '대답하기 전에 생각해야 한다.', 'I need to think before answering.', '答える前に考える必要があります。', 'Necesito ____ antes de responder.'],
  'creer': ['No puedo creer esta noticia.', '나는 이 뉴스를 믿을 수 없다.', 'I cannot believe this news.', 'このニュースを信じられません。', 'No puedo ____ esta noticia.'],
  'saber': ['Quiero saber la verdad.', '나는 진실을 알고 싶다.', 'I want to know the truth.', '真実を知りたいです。', 'Quiero ____ la verdad.'],
  'conocer': ['Me gustaría conocer la ciudad.', '나는 그 도시를 알아가고 싶다.', 'I would like to get to know the city.', 'その街を知りたいです。', 'Me gustaría ____ la ciudad.'],
  'querer': ['Quiero descansar un poco.', '나는 조금 쉬고 싶다.', 'I want to rest a little.', '少し休みたいです。', '____ descansar un poco.'],
  'necesitar': ['Voy a necesitar más tiempo.', '나는 시간이 더 필요할 것이다.', 'I am going to need more time.', 'もっと時間が必要になります。', 'Voy a ____ más tiempo.'],
  'preferir': ['Prefiero viajar en tren.', '나는 기차로 여행하는 것을 선호한다.', 'I prefer to travel by train.', '電車で旅行するほうが好きです。', '____ viajar en tren.'],
  'gustar': ['Me gusta la música latina.', '나는 라틴 음악을 좋아한다.', 'I like Latin music.', 'ラテン音楽が好きです。', 'Me ____ la música latina.'],
  'poder': ['Puedo ayudarte con el proyecto.', '나는 그 프로젝트를 도와줄 수 있다.', 'I can help you with the project.', 'そのプロジェクトを手伝えます。', '____ ayudarte con el proyecto.'],
  'deber': ['Debo estudiar antes del examen.', '나는 시험 전에 공부해야 한다.', 'I must study before the exam.', '試験の前に勉強しなければなりません。', '____ estudiar antes del examen.'],
  'aprender': ['Quiero aprender español este año.', '나는 올해 스페인어를 배우고 싶다.', 'I want to learn Spanish this year.', '今年スペイン語を学びたいです。', 'Quiero ____ español este año.'],
  'enseñar': ['Mi hermana quiere enseñar inglés.', '내 여동생은 영어를 가르치고 싶어 한다.', 'My sister wants to teach English.', '妹は英語を教えたがっています。', 'Mi hermana quiere ____ inglés.'],
  'ayudar': ['Puedo ayudar a mi amigo.', '나는 친구를 도울 수 있다.', 'I can help my friend.', '友達を助けられます。', 'Puedo ____ a mi amigo.'],
  'esperar': ['Tenemos que esperar el autobús.', '우리는 버스를 기다려야 한다.', 'We have to wait for the bus.', 'バスを待たなければなりません。', 'Tenemos que ____ el autobús.'],
  'viajar': ['Me gusta viajar con mi familia.', '나는 가족과 여행하는 것을 좋아한다.', 'I like traveling with my family.', '家族と旅行するのが好きです。', 'Me gusta ____ con mi familia.'],
  'caminar': ['Vamos a caminar por la playa.', '우리는 해변을 걸을 것이다.', 'We are going to walk along the beach.', '海辺を歩きます。', 'Vamos a ____ por la playa.'],
  'correr': ['Me gusta correr por la mañana.', '나는 아침에 달리는 것을 좋아한다.', 'I like running in the morning.', '朝走るのが好きです。', 'Me gusta ____ por la mañana.'],
  'jugar': ['Los niños quieren jugar en el parque.', '아이들은 공원에서 놀고 싶어 한다.', 'The children want to play in the park.', '子どもたちは公園で遊びたがっています。', 'Los niños quieren ____ en el parque.'],
  'ganar': ['El equipo quiere ganar el partido.', '그 팀은 경기에서 이기고 싶어 한다.', 'The team wants to win the match.', 'チームは試合に勝ちたがっています。', 'El equipo quiere ____ el partido.'],
  'perder': ['No quiero perder mi pasaporte.', '나는 여권을 잃어버리고 싶지 않다.', 'I do not want to lose my passport.', 'パスポートをなくしたくありません。', 'No quiero ____ mi pasaporte.'],
  'cambiar': ['Necesito cambiar dinero en el banco.', '나는 은행에서 돈을 환전해야 한다.', 'I need to exchange money at the bank.', '銀行で両替する必要があります。', 'Necesito ____ dinero en el banco.'],
  'empezar': ['La clase va a empezar pronto.', '수업이 곧 시작할 것이다.', 'The class is going to start soon.', '授業がもうすぐ始まります。', 'La clase va a ____ pronto.'],
  'terminar': ['Quiero terminar el trabajo hoy.', '나는 오늘 일을 끝내고 싶다.', 'I want to finish the work today.', '今日仕事を終えたいです。', 'Quiero ____ el trabajo hoy.'],

  'bueno': ['Este café es bueno.', '이 커피는 좋다.', 'This coffee is good.', 'このコーヒーはおいしいです。', 'Este café es ____.'],
  'malo': ['El tiempo es malo hoy.', '오늘 날씨가 나쁘다.', 'The weather is bad today.', '今日は天気が悪いです。', 'El tiempo es ____ hoy.'],
  'grande': ['La habitación es grande.', '그 방은 크다.', 'The room is big.', 'その部屋は大きいです。', 'La habitación es ____.'],
  'pequeño': ['El hotel es pequeño pero cómodo.', '그 호텔은 작지만 편안하다.', 'The hotel is small but comfortable.', 'そのホテルは小さいですが快適です。', 'El hotel es ____ pero cómodo.'],
  'nuevo': ['Tengo un teléfono nuevo.', '나는 새 전화기를 가지고 있다.', 'I have a new phone.', '新しい電話を持っています。', 'Tengo un teléfono ____.'],
  'viejo': ['El libro viejo está en la mesa.', '오래된 책이 탁자 위에 있다.', 'The old book is on the table.', '古い本が机の上にあります。', 'El libro ____ está en la mesa.'],
  'joven': ['Mi profesor es joven.', '내 선생님은 젊다.', 'My teacher is young.', '私の先生は若いです。', 'Mi profesor es ____.'],
  'bonito': ['El parque es bonito en primavera.', '그 공원은 봄에 예쁘다.', 'The park is pretty in spring.', 'その公園は春にきれいです。', 'El parque es ____ en primavera.'],
  'fácil': ['La pregunta es fácil.', '그 질문은 쉽다.', 'The question is easy.', 'その質問は簡単です。', 'La pregunta es ____.'],
  'difícil': ['El examen es difícil.', '그 시험은 어렵다.', 'The exam is difficult.', 'その試験は難しいです。', 'El examen es ____.'],
  'rápido': ['El tren es rápido.', '그 기차는 빠르다.', 'The train is fast.', 'その電車は速いです。', 'El tren es ____.'],
  'lento': ['El servicio es lento hoy.', '오늘 서비스가 느리다.', 'The service is slow today.', '今日はサービスが遅いです。', 'El servicio es ____ hoy.'],
  'caro': ['Este billete es caro.', '이 표는 비싸다.', 'This ticket is expensive.', 'この切符は高いです。', 'Este billete es ____.'],
  'barato': ['El menú del día es barato.', '오늘의 메뉴는 싸다.', 'The daily menu is cheap.', '日替わりメニューは安いです。', 'El menú del día es ____.'],
  'limpio': ['El baño está limpio.', '욕실은 깨끗하다.', 'The bathroom is clean.', '浴室は清潔です。', 'El baño está ____.'],
  'feliz': ['Estoy feliz con la noticia.', '나는 그 소식에 행복하다.', 'I am happy about the news.', 'その知らせでうれしいです。', 'Estoy ____ con la noticia.'],
  'triste': ['Ana está triste esta noche.', '아나는 오늘 밤 슬프다.', 'Ana is sad tonight.', 'アナは今夜悲しんでいます。', 'Ana está ____ esta noche.'],
  'importante': ['La reunión es importante.', '그 회의는 중요하다.', 'The meeting is important.', 'その会議は重要です。', 'La reunión es ____.'],
  'necesario': ['Es necesario llevar pasaporte.', '여권을 지참하는 것이 필요하다.', 'It is necessary to carry a passport.', 'パスポートを持つことが必要です。', 'Es ____ llevar pasaporte.'],
  'posible': ['Es posible cambiar la fecha.', '날짜를 바꾸는 것이 가능하다.', 'It is possible to change the date.', '日付を変えることは可能です。', 'Es ____ cambiar la fecha.'],

  'hoy': ['Hoy tengo una reunión importante.', '오늘 중요한 회의가 있다.', 'Today I have an important meeting.', '今日は大事な会議があります。', '____ tengo una reunión importante.'],
  'ayer': ['Ayer compré un billete de tren.', '어제 기차표를 샀다.', 'Yesterday I bought a train ticket.', '昨日電車の切符を買いました。', '____ compré un billete de tren.'],
  'siempre': ['Siempre desayuno con café.', '나는 항상 커피와 함께 아침을 먹는다.', 'I always have breakfast with coffee.', 'いつもコーヒーと朝食を取ります。', '____ desayuno con café.'],
  'nunca': ['Nunca salgo sin mi teléfono.', '나는 절대 전화기 없이 나가지 않는다.', 'I never go out without my phone.', '電話なしでは決して外出しません。', '____ salgo sin mi teléfono.'],
  'a veces': ['A veces estudio en la biblioteca.', '나는 가끔 도서관에서 공부한다.', 'Sometimes I study in the library.', '時々図書館で勉強します。', '____ estudio en la biblioteca.'],
  'también': ['Yo también quiero viajar.', '나도 여행하고 싶다.', 'I also want to travel.', '私も旅行したいです。', 'Yo ____ quiero viajar.'],
  'muy': ['La comida está muy buena.', '음식이 매우 맛있다.', 'The food is very good.', '料理はとてもおいしいです。', 'La comida está ____ buena.'],
  'poco': ['Tengo poco tiempo esta mañana.', '오늘 아침 시간이 거의 없다.', 'I have little time this morning.', '今朝は時間があまりありません。', 'Tengo ____ tiempo esta mañana.'],
  'mucho': ['Trabajo mucho durante la semana.', '나는 주중에 많이 일한다.', 'I work a lot during the week.', '平日はたくさん働きます。', 'Trabajo ____ durante la semana.'],
  'más': ['Necesito más agua.', '물이 더 필요하다.', 'I need more water.', 'もっと水が必要です。', 'Necesito ____ agua.'],
  'menos': ['Quiero menos azúcar en el café.', '커피에 설탕을 덜 넣고 싶다.', 'I want less sugar in the coffee.', 'コーヒーの砂糖を少なめにしたいです。', 'Quiero ____ azúcar en el café.'],
  'antes': ['Llega antes de las ocho.', '여덟 시 전에 도착해라.', 'Arrive before eight.', '8時前に着いてください。', 'Llega ____ de las ocho.'],
  'después': ['Hablamos después de la clase.', '수업 후에 이야기하자.', 'We talk after class.', '授業の後で話しましょう。', 'Hablamos ____ de la clase.'],
  'aquí': ['Aquí está tu pasaporte.', '여기에 네 여권이 있다.', 'Here is your passport.', 'ここにあなたのパスポートがあります。', '____ está tu pasaporte.'],
  'allí': ['Allí está la estación de tren.', '저기에 기차역이 있다.', 'There is the train station.', 'あそこに駅があります。', '____ está la estación de tren.'],
  'cerca': ['La farmacia está cerca del hotel.', '약국은 호텔에서 가깝다.', 'The pharmacy is near the hotel.', '薬局はホテルの近くにあります。', 'La farmacia está ____ del hotel.'],
  'lejos': ['El aeropuerto está lejos del centro.', '공항은 중심가에서 멀다.', 'The airport is far from downtown.', '空港は中心部から遠いです。', 'El aeropuerto está ____ del centro.'],
  'porque': ['Me quedo en casa porque estoy cansado.', '피곤해서 집에 머문다.', 'I stay at home because I am tired.', '疲れているので家にいます。', 'Me quedo en casa ____ estoy cansado.'],
  'pero': ['Quiero ir, pero no tengo tiempo.', '가고 싶지만 시간이 없다.', 'I want to go, but I do not have time.', '行きたいですが、時間がありません。', 'Quiero ir, ____ no tengo tiempo.'],
};

function setEntry(entry, data) {
  const [example, ko, en, ja, blank] = data;
  entry.example = example;
  entry.exampleMeanings = {ko, en, ja};
  entry.blankedExample = blank;
  entry.answer = blank.includes('____') ? entry.answer : entry.spanish;
}

const removeGenerated = new Set();
for (const entry of entries) {
  const ko = entry.meanings?.ko || '';
  if (entry.partOfSpeech === 'noun' && ko.endsWith('들')) {
    removeGenerated.add(entry);
  }
  if (/ en español\.?$/.test(entry.example || '') && !updates[entry.spanish]) {
    removeGenerated.add(entry);
  }
  if (/Las respuestas son /.test(entry.example || '')) {
    removeGenerated.add(entry);
  }
}

const cleaned = [];
const seen = new Set();
for (const entry of entries) {
  if (removeGenerated.has(entry)) continue;
  if (seen.has(entry.spanish)) continue;
  seen.add(entry.spanish);
  if (updates[entry.spanish]) setEntry(entry, updates[entry.spanish]);
  cleaned.push(entry);
}

fs.writeFileSync(path, JSON.stringify(cleaned), 'utf8');
console.log(`cleaned ${entries.length} -> ${cleaned.length}`);
