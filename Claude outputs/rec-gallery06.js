/* GALLERY06(곡면 갤러리) 미리보기 녹화 — 편집기 콘솔(F12 → Console)에 통째로 붙여넣고 Enter.
   · 페이지 화면이 아니라 블럭 캔버스만 녹화한다(스크롤·커서·선택 테두리가 안 찍힘)
   · 움직임은 스크립트가 넣는 드래그 두 번(관성 포함) — 마우스는 건드리지 말 것
   · 끝나면 gallery06-rec.webm 이 내려받아진다 → editor-assets 폴더에 넣어 주면 자르기·인코딩은 이쪽에서 */
(async function(){
  var blk=document.querySelector('#stage .blk[data-block="infgal"]');
  if(!blk){ alert('곡면 갤러리(GALLERY06) 블럭을 먼저 하나 추가해 주세요.'); return; }
  var wrap=blk.querySelector('.ig-wrap'), cv=wrap.querySelector('canvas.ig-gl'), S=blk._ig;
  blk.scrollIntoView({block:'center'});
  var sleep=function(ms){ return new Promise(function(r){ setTimeout(r,ms); }); };
  await sleep(3000);                                   /* 등장 애니메이션·텍스처 로딩 대기 */
  if(S) S.lastAct=performance.now();                   /* 대기 중 자동 흐름(drift)이 끼지 않게 */

  var rect=wrap.getBoundingClientRect();
  function P(fx,fy){ return {x:rect.left+rect.width*fx, y:rect.top+rect.height*fy}; }
  function ev(type,p,btn){ wrap.dispatchEvent(new PointerEvent(type,{bubbles:true,cancelable:true,pointerId:7,pointerType:'mouse',isPrimary:true,
    clientX:p.x,clientY:p.y,button:0,buttons:btn?1:0})); }
  function ease(t){ return t<.5?4*t*t*t:1-Math.pow(-2*t+2,3)/2; }
  function frame(){ return new Promise(function(r){ requestAnimationFrame(r); }); }
  async function drag(a,b,ms){
    var t0=performance.now(); ev('pointermove',a,false); ev('pointerdown',a,true);
    for(;;){ await frame(); var k=Math.min(1,(performance.now()-t0)/ms), e=ease(k);
      ev('pointermove',{x:a.x+(b.x-a.x)*e, y:a.y+(b.y-a.y)*e},true); if(k>=1) break; }
    ev('pointerup',b,false);
  }

  var stream=cv.captureStream(30);
  var mime=MediaRecorder.isTypeSupported('video/webm;codecs=vp9')?'video/webm;codecs=vp9':'video/webm';
  var rec=new MediaRecorder(stream,{mimeType:mime,videoBitsPerSecond:12000000}), chunks=[];
  rec.ondataavailable=function(e){ if(e.data.size) chunks.push(e.data); };
  var done=new Promise(function(r){ rec.onstop=r; });
  rec.start();

  await sleep(300);
  await drag(P(.60,.62),P(.34,.36),1300);             /* 왼쪽 위로 끌었다 놓기 → 관성 */
  await sleep(700);
  await drag(P(.38,.40),P(.66,.58),1100);             /* 오른쪽 아래로 되돌리기 */
  ev('pointerleave',P(1.2,1.2),false);
  await sleep(1100);

  rec.stop(); await done;
  var a=document.createElement('a'); a.href=URL.createObjectURL(new Blob(chunks,{type:'video/webm'}));
  a.download='gallery06-rec.webm'; document.body.appendChild(a); a.click(); a.remove();
  console.log('녹화 끝 — gallery06-rec.webm', cv.width+'x'+cv.height);
})();
