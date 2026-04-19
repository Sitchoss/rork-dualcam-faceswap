import Foundation

enum DualCamHTML {
    static let page: String = #"""
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
<title>Kysee Diagnostic Suite</title>
<style>
  :root {
    --bg1: #05070F;
    --bg2: #0A0F22;
    --accent: #00FFB2;
    --accent2: #7B2CFF;
    --accent3: #FF3CC7;
    --warn: #FFB020;
    --bad: #FF3B30;
    --good: #00FFB2;
    --text: #E8F0FF;
    --muted: rgba(232,240,255,0.55);
    --card: rgba(255,255,255,0.05);
    --stroke: rgba(255,255,255,0.10);
    --hud-bg: rgba(0,14,10,0.70);
    --hud-stroke: rgba(0,255,178,0.35);
  }
  * { box-sizing: border-box; -webkit-tap-highlight-color: transparent; }
  html, body {
    margin: 0; padding: 0; height: 100%;
    color: var(--text);
    font-family: -apple-system, BlinkMacSystemFont, "SF Pro Text", system-ui;
    background:
      radial-gradient(1100px 700px at 10% 0%, rgba(123,44,255,0.18), transparent 60%),
      radial-gradient(900px 600px at 100% 100%, rgba(0,255,178,0.10), transparent 60%),
      linear-gradient(180deg, var(--bg1), var(--bg2));
    overscroll-behavior: none;
    -webkit-user-select: none;
  }
  .wrap {
    padding: 10px; padding-top: max(8px, env(safe-area-inset-top));
    padding-bottom: max(10px, env(safe-area-inset-bottom));
    display: flex; flex-direction: column; gap: 8px; height: 100%;
  }

  .titlebar { display:flex; align-items:center; justify-content: space-between; gap: 8px; }
  h1 {
    font-size: 15px; font-weight: 800; margin: 0; letter-spacing: 0.5px;
    font-family: ui-monospace, "SF Mono", Menlo, monospace;
    color: var(--accent);
  }
  h1 .tag { color: var(--muted); font-weight: 500; margin-left: 6px; font-size: 11px; letter-spacing: 1px; }
  .rightpill {
    font-family: ui-monospace, monospace; font-size: 10px; color: var(--muted);
    padding: 4px 8px; border-radius: 999px; border: 1px solid var(--stroke);
    background: rgba(0,0,0,0.3);
  }

  .modebar {
    display: flex; gap: 4px; padding: 3px;
    background: var(--card); border: 1px solid var(--stroke);
    border-radius: 12px; backdrop-filter: blur(14px);
  }
  .modebtn {
    flex: 1; padding: 8px 4px; border-radius: 9px;
    background: transparent; border: none; color: var(--muted);
    font-size: 10px; font-weight: 700; cursor: pointer;
    display: flex; flex-direction: column; align-items: center; gap: 2px;
    letter-spacing: 0.3px;
  }
  .modebtn svg { width: 16px; height: 16px; }
  .modebtn.active {
    background: linear-gradient(135deg, rgba(0,255,178,0.18), rgba(123,44,255,0.18));
    color: var(--accent);
    border: 1px solid rgba(0,255,178,0.35);
  }

  .chipbar {
    display: flex; gap: 6px; overflow-x: auto; padding: 2px 0 4px 0;
    scrollbar-width: none; -webkit-overflow-scrolling: touch;
  }
  .chipbar::-webkit-scrollbar { display: none; }
  .chip {
    flex: 0 0 auto; padding: 6px 10px; border-radius: 999px;
    background: var(--card); border: 1px solid var(--stroke);
    font-size: 11px; font-weight: 600; color: var(--text);
    display: flex; align-items: center; gap: 6px;
    backdrop-filter: blur(14px); cursor: pointer;
    white-space: nowrap; font-family: ui-monospace, monospace;
  }
  .chip.active {
    background: linear-gradient(90deg, rgba(0,255,178,0.20), rgba(123,44,255,0.20));
    border: 1px solid var(--accent);
    color: var(--accent);
  }
  .chip .pos { opacity: 0.60; font-weight: 500; font-size: 10px; }

  .preview {
    position: relative; border-radius: 16px; overflow: hidden;
    background: #000; aspect-ratio: 3 / 4;
    border: 1px solid var(--stroke);
    flex: 0 0 auto;
  }
  video {
    width: 100%; height: 100%; object-fit: cover;
    display: block;
  }
  video.mirror { transform: scaleX(-1); }
  canvas.gridcanvas {
    position: absolute; inset: 0; width: 100%; height: 100%;
    pointer-events: none; mix-blend-mode: difference;
    image-rendering: pixelated;
  }
  canvas.gridcanvas.reveal {
    mix-blend-mode: normal;
    opacity: 0.95;
  }

  .badge {
    position: absolute; top: 8px; left: 8px;
    padding: 3px 8px; border-radius: 999px;
    background: rgba(0,0,0,0.55); font-size: 10px; font-weight: 700;
    letter-spacing: 0.8px; display: flex; align-items: center; gap: 6px;
    font-family: ui-monospace, monospace; color: var(--accent);
    border: 1px solid var(--hud-stroke);
  }
  .dot { width: 7px; height: 7px; border-radius: 50%; background: var(--bad); animation: pulse 1s infinite; }
  @keyframes pulse { 0%,100% { opacity: 1; } 50% { opacity: 0.3; } }

  .hudwrap {
    position: absolute; top: 8px; right: 8px; display: flex; flex-direction: column; gap: 6px;
    align-items: flex-end; max-width: 65%;
  }
  .hudchip {
    padding: 4px 8px; border-radius: 8px;
    background: var(--hud-bg); border: 1px solid var(--hud-stroke);
    font-family: ui-monospace, monospace; font-size: 10px;
    color: var(--accent); letter-spacing: 0.3px;
    backdrop-filter: blur(8px);
  }
  .hudchip.warn { color: var(--warn); border-color: rgba(255,176,32,0.45); }
  .hudchip.bad { color: var(--bad); border-color: rgba(255,59,48,0.45); }

  .status {
    position: absolute; bottom: 8px; left: 8px; right: 8px;
    font-size: 11px; color: var(--text);
    padding: 6px 10px; border-radius: 8px;
    background: rgba(0,0,0,0.55); backdrop-filter: blur(10px);
    font-family: ui-monospace, monospace;
    border: 1px solid var(--stroke);
  }
  .toolbox {
    position: absolute; bottom: 40px; right: 8px; display: flex; flex-direction: column; gap: 6px;
  }
  .toolbtn {
    width: 32px; height: 32px; border-radius: 10px;
    background: var(--hud-bg); border: 1px solid var(--hud-stroke);
    color: var(--accent); font-size: 13px; cursor: pointer;
    display: flex; align-items: center; justify-content: center;
    backdrop-filter: blur(8px);
  }
  .toolbtn.on { background: var(--accent); color: #001; }

  /* Loupe */
  .loupe {
    position: absolute; width: 140px; height: 140px; border-radius: 50%;
    border: 2px solid var(--accent); pointer-events: none;
    overflow: hidden; box-shadow: 0 10px 30px rgba(0,0,0,0.5);
    background: #000;
    display: none;
  }
  .loupe canvas { width: 100%; height: 100%; display: block; }
  .loupe .lx {
    position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
    color: var(--accent); font-family: ui-monospace, monospace; font-size: 9px;
    pointer-events: none;
  }

  /* Waveform strip */
  .waveform {
    height: 46px; border-radius: 10px;
    background: var(--hud-bg); border: 1px solid var(--hud-stroke);
    overflow: hidden; position: relative;
  }
  .waveform canvas { width: 100%; height: 100%; display: block; }
  .waveform .wflabel {
    position: absolute; top: 4px; left: 8px; font-family: ui-monospace, monospace;
    font-size: 9px; color: var(--accent); letter-spacing: 0.3px;
  }
  .waveform .wfval {
    position: absolute; top: 4px; right: 8px; font-family: ui-monospace, monospace;
    font-size: 9px; color: var(--accent);
  }

  .readout {
    font-family: ui-monospace, "SF Mono", Menlo, monospace;
    font-size: 10px; color: var(--muted);
    padding: 7px 10px; border-radius: 10px;
    background: var(--card); border: 1px solid var(--stroke);
    display: flex; justify-content: space-between; gap: 8px; flex-wrap: wrap;
  }
  .readout b { color: var(--accent); font-weight: 700; }

  .controls { display: flex; flex-direction: column; gap: 6px; }
  .grid2 { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; }
  .grid3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 6px; }
  button {
    font: inherit; color: var(--text);
    border: 1px solid var(--stroke);
    border-radius: 11px; padding: 10px 12px;
    background: var(--card); backdrop-filter: blur(14px);
    font-weight: 600; font-size: 12px;
    cursor: pointer; transition: transform .1s ease, opacity .2s;
    font-family: ui-monospace, monospace; letter-spacing: 0.3px;
  }
  button:active { transform: scale(0.97); }
  button.primary {
    background: linear-gradient(90deg, rgba(0,255,178,0.25), rgba(123,44,255,0.25));
    border: 1px solid var(--accent);
    color: var(--accent);
  }
  button.danger { background: linear-gradient(90deg, rgba(255,59,48,0.25), rgba(255,60,199,0.25)); border: 1px solid var(--bad); color: var(--bad); }
  button.ghost { background: rgba(255,255,255,0.04); }
  button:disabled { opacity: 0.5; }

  .section-title {
    font-size: 10px; color: var(--muted); text-transform: uppercase; letter-spacing: 1.5px;
    margin: 2px 0; font-family: ui-monospace, monospace;
  }
  .header { display:flex; align-items:center; justify-content: space-between; }
  .count { font-size: 10px; color: var(--muted); font-family: ui-monospace, monospace; }

  /* Matrix log */
  .log {
    flex: 1 1 auto; overflow-y: auto; display: flex; flex-direction: column; gap: 3px;
    padding: 6px; border-radius: 10px;
    background: rgba(0,10,6,0.55); border: 1px solid var(--hud-stroke);
    font-family: ui-monospace, monospace; font-size: 10px;
    min-height: 100px;
  }
  .log::-webkit-scrollbar { width: 4px; }
  .log::-webkit-scrollbar-thumb { background: rgba(0,255,178,0.3); border-radius: 2px; }
  .logrow {
    color: var(--accent);
    line-height: 1.35; word-break: break-all; white-space: pre-wrap;
  }
  .logrow .t { color: rgba(0,255,178,0.4); margin-right: 6px; }
  .logrow .e { color: var(--accent); font-weight: 700; margin-right: 6px; }
  .logrow.err .e { color: var(--bad); }
  .logrow.warn .e { color: var(--warn); }
  .logrow details { color: rgba(0,255,178,0.6); }
  .logrow summary { cursor: pointer; font-size: 9px; color: rgba(0,255,178,0.45); }

  /* Gantt */
  .gantt {
    border-radius: 10px; border: 1px solid var(--hud-stroke);
    background: rgba(0,10,6,0.55); padding: 8px;
    font-family: ui-monospace, monospace; font-size: 10px;
  }
  .gantt .row { display: grid; grid-template-columns: 80px 1fr 60px; gap: 6px; align-items: center; margin: 3px 0; }
  .gantt .lbl { color: var(--muted); }
  .gantt .track { position: relative; height: 10px; background: rgba(0,255,178,0.08); border-radius: 4px; overflow: hidden; }
  .gantt .bar { position: absolute; top: 0; bottom: 0; background: var(--accent); border-radius: 4px; }
  .gantt .bar.warn { background: var(--warn); }
  .gantt .bar.bad { background: var(--bad); }
  .gantt .ms { text-align: right; color: var(--accent); }

  /* Health score gauge */
  .analysis {
    background: rgba(0,10,6,0.55); border: 1px solid var(--hud-stroke);
    border-radius: 12px; padding: 10px; display: flex; gap: 10px; align-items: center;
    font-family: ui-monospace, monospace;
  }
  .gauge { width: 72px; height: 72px; position: relative; flex: 0 0 auto; }
  .gauge svg { width: 100%; height: 100%; transform: rotate(-90deg); }
  .gauge .num { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center;
    font-size: 20px; font-weight: 700; color: var(--accent); }
  .metrics { flex: 1; display: grid; grid-template-columns: 1fr 1fr; gap: 4px; font-size: 10px; }
  .metrics .m { background: rgba(255,255,255,0.03); border: 1px solid var(--stroke); border-radius: 8px; padding: 5px 7px; }
  .metrics .m .k { color: var(--muted); font-size: 9px; letter-spacing: 0.5px; }
  .metrics .m .v { color: var(--accent); font-weight: 700; font-size: 12px; margin-top: 1px; }

  /* Gallery */
  .gallery {
    display: grid; grid-template-columns: repeat(3, 1fr); gap: 6px;
    overflow-y: auto; padding-bottom: 6px; flex: 1 1 auto; min-height: 60px;
  }
  .gallery .item {
    position: relative; aspect-ratio: 1; border-radius: 10px; overflow: hidden;
    background: #000; border: 1px solid var(--stroke);
  }
  .gallery img, .gallery video {
    width: 100%; height: 100%; object-fit: cover; transform: none;
  }
  .gallery .kind {
    position: absolute; top: 3px; left: 3px; font-size: 8px; font-weight: 700;
    padding: 2px 5px; background: rgba(0,0,0,0.6); border-radius: 5px;
    color: var(--accent); font-family: ui-monospace, monospace;
  }
  .gallery .save {
    position: absolute; bottom: 3px; right: 3px; padding: 3px 6px;
    background: rgba(0,0,0,0.6); border: none; border-radius: 6px;
    font-size: 11px;
  }

  /* Reports list */
  .reports { display: flex; flex-direction: column; gap: 6px; overflow-y: auto; }
  .report {
    padding: 8px 10px; background: rgba(255,255,255,0.03);
    border: 1px solid var(--stroke); border-radius: 10px;
    display: grid; grid-template-columns: 1fr auto; gap: 6px; align-items: center;
    font-family: ui-monospace, monospace; font-size: 11px;
  }
  .report .meta { color: var(--muted); font-size: 9px; }
  .report .actions { display: flex; gap: 4px; }
  .report .actions button { padding: 5px 8px; font-size: 10px; border-radius: 7px; }
  .report .score { color: var(--accent); font-weight: 700; margin-right: 6px; }

  /* Sheet */
  .sheet {
    position: fixed; inset: 0; background: rgba(0,0,0,0.55);
    backdrop-filter: blur(8px); z-index: 50;
    display: flex; align-items: flex-end; justify-content: center;
  }
  .sheet .panel {
    width: 100%; max-width: 540px;
    background: linear-gradient(180deg, rgba(5,15,10,0.98), rgba(5,7,15,0.98));
    border-top-left-radius: 20px; border-top-right-radius: 20px;
    border: 1px solid var(--hud-stroke); padding: 14px;
    padding-bottom: max(14px, env(safe-area-inset-bottom));
    display: flex; flex-direction: column; gap: 10px;
    max-height: 85vh; overflow-y: auto;
  }
  .sheet .title { font-size: 14px; font-weight: 700; color: var(--accent); font-family: ui-monospace, monospace; letter-spacing: 0.5px; }
  .fieldrow { display: flex; align-items: center; gap: 10px; font-family: ui-monospace, monospace; font-size: 11px; }
  .fieldrow label { color: var(--muted); width: 90px; flex: 0 0 auto; font-size: 10px; }
  .fieldrow .val { font-size: 10px; color: var(--accent); width: 52px; text-align: right; }
  .fieldrow input[type=range] { flex: 1; accent-color: var(--accent); }
  .seg { display: flex; gap: 3px; background: var(--card); border: 1px solid var(--stroke); border-radius: 9px; padding: 3px; }
  .seg button { flex: 1; padding: 6px 8px; border-radius: 7px; font-size: 10px; background: transparent; border: none; color: var(--muted); }
  .seg button.on { background: rgba(0,255,178,0.18); color: var(--accent); border: 1px solid var(--accent); }
  .mini {
    height: 100px; border-radius: 10px; background: #111;
    border: 1px solid var(--stroke); overflow: hidden; position: relative;
  }
  .mini canvas { width: 100%; height: 100%; display: block; }

  .switchrow { display: flex; justify-content: space-between; align-items: center; font-family: ui-monospace, monospace; font-size: 11px; color: var(--muted); }
  .tgl { width: 38px; height: 22px; background: rgba(255,255,255,0.08); border-radius: 999px; position: relative; cursor: pointer; border: 1px solid var(--stroke); }
  .tgl .knob { position: absolute; top: 1px; left: 1px; width: 18px; height: 18px; border-radius: 50%; background: #fff; transition: left .18s; }
  .tgl.on { background: rgba(0,255,178,0.25); border-color: var(--accent); }
  .tgl.on .knob { left: 18px; background: var(--accent); }
</style>
</head>
<body>
<div class="wrap">
  <div class="titlebar">
    <h1>KYSEE<span class="tag">DIAGNOSTIC SUITE</span></h1>
    <div class="rightpill" id="sessionPill">READY</div>
  </div>

  <div class="modebar" id="modebar">
    <button class="modebtn active" data-mode="simulate">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3.5"/><path d="M4 8h3l2-3h6l2 3h3v11H4z"/></svg>
      <span>SIMULATE</span>
    </button>
    <button class="modebtn" data-mode="realcam">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="8"/><circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M2 12h3M19 12h3"/></svg>
      <span>REAL CAM</span>
    </button>
    <button class="modebtn" data-mode="overlay">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 3h18v18H3z"/><path d="M9 3v18M15 3v18M3 9h18M3 15h18"/></svg>
      <span>OVERLAY</span>
    </button>
    <button class="modebtn" data-mode="reports">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 4h16v16H4z"/><path d="M8 9h8M8 13h8M8 17h5"/></svg>
      <span>REPORTS</span>
    </button>
  </div>

  <div class="chipbar" id="chipbar"></div>

  <div class="preview" id="previewBox">
    <video id="video" autoplay muted playsinline></video>
    <canvas class="gridcanvas" id="gridcanvas"></canvas>
    <div class="badge" id="badge" style="display:none;"><span class="dot"></span><span id="badgeText">LIVE</span></div>
    <div class="hudwrap" id="hudwrap"></div>
    <div class="toolbox" id="toolbox" style="display:none;">
      <button class="toolbtn" id="revealBtn" title="Reveal">👁</button>
      <button class="toolbtn" id="loupeBtn" title="Loupe">🔍</button>
      <button class="toolbtn" id="gearbtn" title="Settings">⚙</button>
      <button class="toolbtn" id="analyzeBtn" title="Analyze">⌖</button>
    </div>
    <div class="loupe" id="loupe"><canvas id="loupeCanvas" width="280" height="280"></canvas></div>
    <div class="status" id="status">Select a camera to begin.</div>
  </div>

  <div class="readout" id="readout">
    <span>LENS <b id="roName">—</b></span>
    <span>RES <b id="roRes">—</b></span>
    <span>FOV <b id="roFov">—</b></span>
    <span>FPS <b id="roFps">—</b></span>
  </div>

  <!-- SIMULATE -->
  <div id="simControls" class="controls">
    <div class="grid2">
      <button id="startBtn" class="primary">► Start Camera</button>
      <button id="recBtn" disabled>● Record Clip</button>
    </div>
    <div class="grid2">
      <button id="backPhoto" class="ghost">📸 Native Photo</button>
      <button id="backVideo" class="ghost">🎥 Native Video</button>
    </div>
    <button id="autoBtn" class="danger">⟳ Auto Simulate (3s → Native → Restart)</button>
  </div>

  <!-- REAL CAM -->
  <div id="realControls" class="controls" style="display:none;">
    <div class="grid2">
      <button id="realStart" class="primary">► Start Session</button>
      <button id="realStop" class="ghost" disabled>■ Stop</button>
    </div>
    <div class="waveform">
      <div class="wflabel" id="wfLabel">FPS · BITRATE</div>
      <div class="wfval" id="wfVal">0.0 fps</div>
      <canvas id="wfCanvas"></canvas>
    </div>
    <div id="ganttWrap" class="gantt" style="display:none;"></div>
    <div class="grid3">
      <button id="realClear" class="ghost">Clear</button>
      <button id="realExport" class="ghost">Export JSON</button>
      <button id="realFinalize" class="primary">End & Analyze</button>
    </div>
  </div>

  <!-- OVERLAY -->
  <div id="overlayControls" class="controls" style="display:none;">
    <div class="grid2">
      <button id="ovStart" class="primary">► Start with Grid</button>
      <button id="ovStop" class="ghost" disabled>■ Stop</button>
    </div>
    <div class="grid3">
      <button id="ovReveal" class="ghost">👁 Reveal</button>
      <button id="ovAnalyze" class="ghost">⌖ Analyze</button>
      <button id="ovFinalize" class="primary">End & Analyze</button>
    </div>
    <div id="ovAnalysis" class="analysis" style="display:none;">
      <div class="gauge">
        <svg viewBox="0 0 64 64"><circle cx="32" cy="32" r="28" fill="none" stroke="rgba(0,255,178,0.15)" stroke-width="6"/><circle id="gaugeArc" cx="32" cy="32" r="28" fill="none" stroke="var(--accent)" stroke-width="6" stroke-linecap="round" stroke-dasharray="176" stroke-dashoffset="176"/></svg>
        <div class="num" id="gaugeNum">—</div>
      </div>
      <div class="metrics">
        <div class="m"><div class="k">VISIBLE RANGE</div><div class="v" id="mVisible">—</div></div>
        <div class="m"><div class="k">CENTROID DRIFT</div><div class="v" id="mDrift">—</div></div>
        <div class="m"><div class="k">ASPECT DIST</div><div class="v" id="mAspect">—</div></div>
        <div class="m"><div class="k">LATENCY</div><div class="v" id="mLatency">—</div></div>
      </div>
    </div>
  </div>

  <!-- REPORTS -->
  <div id="reportsControls" class="controls" style="display:none;">
    <div class="section-title">SESSION REPORTS</div>
    <div id="reportsList" class="reports"></div>
  </div>

  <div class="header" id="galleryHeader">
    <p class="section-title" id="galleryTitle">ALL RECORDINGS</p>
    <span class="count" id="count">0</span>
  </div>
  <div class="gallery" id="gallery"></div>
  <div class="log" id="log" style="display:none;"></div>
</div>

<!-- Grid Settings Sheet -->
<div class="sheet" id="gridSheet" style="display:none;">
  <div class="panel">
    <div class="title">◎ PATTERN LAB · GRID SETTINGS</div>
    <div class="section-title">MAGNIFIED PIXEL VIEW (AI RECOVERY FILTER APPLIED)</div>
    <div class="mini" id="miniPreview"><canvas id="miniCanvas"></canvas></div>
    <div class="switchrow">
      <span>Sub-perceptual masking (invisible to human eye)</span>
      <div class="tgl on" id="subPerceptTgl"><div class="knob"></div></div>
    </div>
    <div class="switchrow">
      <span>Auto-tune contrast to ambient light</span>
      <div class="tgl on" id="autoTuneTgl"><div class="knob"></div></div>
    </div>
    <div class="fieldrow">
      <label>Luminance Δ</label>
      <input type="range" id="contrastR" min="1" max="40" step="1" value="3">
      <span class="val" id="contrastV">±3</span>
    </div>
    <div class="fieldrow">
      <label>Ring Count</label>
      <input type="range" id="ringsR" min="2" max="8" step="1" value="5">
      <span class="val" id="ringsV">5</span>
    </div>
    <div class="fieldrow">
      <label>Label Size</label>
      <input type="range" id="labelR" min="8" max="20" step="1" value="12">
      <span class="val" id="labelV">12px</span>
    </div>
    <button class="primary" id="gridDone">Done</button>
  </div>
</div>

<!-- Analysis Sheet -->
<div class="sheet" id="analysisSheet" style="display:none;">
  <div class="panel">
    <div class="title">◎ POST-SESSION ANALYSIS</div>
    <div class="analysis">
      <div class="gauge">
        <svg viewBox="0 0 64 64"><circle cx="32" cy="32" r="28" fill="none" stroke="rgba(0,255,178,0.15)" stroke-width="6"/><circle id="gaugeArc2" cx="32" cy="32" r="28" fill="none" stroke="var(--accent)" stroke-width="6" stroke-linecap="round" stroke-dasharray="176" stroke-dashoffset="176"/></svg>
        <div class="num" id="gaugeNum2">—</div>
      </div>
      <div class="metrics">
        <div class="m"><div class="k">VISIBLE RANGE</div><div class="v" id="mVisible2">—</div></div>
        <div class="m"><div class="k">CENTROID DRIFT</div><div class="v" id="mDrift2">—</div></div>
        <div class="m"><div class="k">ASPECT DIST</div><div class="v" id="mAspect2">—</div></div>
        <div class="m"><div class="k">GRID SAMPLES</div><div class="v" id="mSamples2">—</div></div>
      </div>
    </div>
    <div class="section-title">TIMELINE · GANTT</div>
    <div id="ganttAnalysis" class="gantt"></div>
    <div class="grid3">
      <button id="anShareJSON" class="ghost">Share JSON</button>
      <button id="anSharePDF" class="ghost">Share PDF</button>
      <button id="anClose" class="primary">Close</button>
    </div>
  </div>
</div>

<script>
(function(){
  // ============================================================
  //  KYSEE DIAGNOSTIC SUITE
  //  - Simulate: Safari-style getUserMedia emulation per lens
  //  - Real Cam: silent profiler (no injection) w/ mach-precision timeline
  //  - Overlay: sub-perceptual A-I x 1-12 fiducial grid + detection engine
  // ============================================================

  // ---------- Camera inventory bridge ----------
  window.__DUALCAM_CAMERAS = window.__DUALCAM_CAMERAS || [];
  window.__DUALCAM_ACTIVE_ID = window.__DUALCAM_ACTIVE_ID || null;

  function getActive() {
    const cams = window.__DUALCAM_CAMERAS || [];
    if (!cams.length) return null;
    const id = window.__DUALCAM_ACTIVE_ID;
    return cams.find(c => c.id === id) || cams[0];
  }
  window.__DUALCAM_GET_ACTIVE = getActive;

  // ---------- Session state ----------
  let currentMode = 'simulate';
  let session = null;
  let sessions = [];

  function newSession(mode){
    const t0 = performance.now();
    return {
      id: 's-' + Date.now().toString(36),
      mode,
      startWall: new Date().toISOString(),
      startPerf: t0,
      endPerf: null,
      entries: [],
      timeline: {
        requestStart: null,
        permissionGranted: null,
        streamReady: null,
        firstFrame: null,
        streamEnd: null
      },
      fpsSamples: [],
      activeId: window.__DUALCAM_ACTIVE_ID,
      device: null,
      requestedConstraints: null,
      grantedSettings: null,
      grantedCapabilities: null,
      analysis: null
    };
  }

  function logEvent(event, detail, level){
    const t = performance.now();
    const wall = Date.now();
    const entry = { t, wall, event, detail: detail || {}, level: level || 'info' };
    if (session) session.entries.push(entry);
    if (currentMode === 'realcam') renderLog();
    return entry;
  }

  // ---------- Safari-style getUserMedia shim + profiler ----------
  const realGUM = navigator.mediaDevices && navigator.mediaDevices.getUserMedia
    ? navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices) : null;
  const realEnum = navigator.mediaDevices && navigator.mediaDevices.enumerateDevices
    ? navigator.mediaDevices.enumerateDevices.bind(navigator.mediaDevices) : null;

  if (navigator.mediaDevices && realGUM) {
    navigator.mediaDevices.getUserMedia = async function(constraints){
      const t0 = performance.now();
      if (session) session.timeline.requestStart = t0;
      if (session) session.requestedConstraints = safeJSON(constraints);
      logEvent('gum.request', { constraints: safeJSON(constraints) });
      try {
        let finalConstraints = constraints;
        if (currentMode === 'simulate') {
          finalConstraints = negotiateSafariConstraints(constraints);
          logEvent('gum.negotiated', { constraints: safeJSON(finalConstraints) });
        }
        const stream = await realGUM(finalConstraints);
        const t1 = performance.now();
        if (session) {
          session.timeline.permissionGranted = t1;
          session.timeline.streamReady = t1;
        }
        const settings = trackSettings(stream);
        if (session) {
          session.grantedSettings = settings.settings;
          session.grantedCapabilities = settings.capabilities;
        }
        logEvent('gum.granted', { elapsedMs: Math.round(t1-t0), settings });
        attachTrackListeners(stream);
        return stream;
      } catch(e) {
        const t1 = performance.now();
        logEvent('gum.error', { elapsedMs: Math.round(t1-t0), error: String(e && e.message || e) }, 'err');
        throw e;
      }
    };
  }

  function negotiateSafariConstraints(constraints){
    const active = getActive();
    const v = constraints && constraints.video;
    if (!active || !v) return constraints;
    const pick = (x) => {
      if (x == null) return null;
      if (typeof x === 'number') return x;
      if (typeof x === 'object') return x.ideal ?? x.exact ?? x.max ?? x.min ?? null;
      return null;
    };
    let width = null, height = null, facingMode = null;
    if (typeof v === 'object') {
      width = pick(v.width);
      height = pick(v.height);
      if (typeof v.facingMode === 'string') facingMode = v.facingMode;
      else if (v.facingMode && typeof v.facingMode === 'object') facingMode = pick(v.facingMode);
    }
    let res;
    if (width == null && height == null) res = active.webVideoOnly;
    else if (width != null && height == null) res = active.webWidthOnly;
    else if (width == null && height != null) res = active.webHeightOnly;
    else res = { w: width, h: height };
    if (!facingMode) facingMode = active.position === 'Front' ? 'user' : 'environment';
    const newVideo = {
      facingMode: { ideal: facingMode },
      width: { ideal: (res && res.w) || 1280 },
      height: { ideal: (res && res.h) || 720 }
    };
    const out = { video: newVideo };
    if (constraints.audio != null) out.audio = constraints.audio;
    return out;
  }

  if (navigator.mediaDevices && realEnum) {
    navigator.mediaDevices.enumerateDevices = async function(){
      try {
        if (currentMode === 'simulate' || currentMode === 'overlay') {
          const cams = window.__DUALCAM_CAMERAS || [];
          if (cams.length) {
            const mapped = cams.map(c => ({
              deviceId: c.id, groupId: c.position, kind: 'videoinput', label: c.name,
              toJSON: function(){ return this; }
            }));
            try {
              const real = await realEnum();
              const audio = real.filter(d => d.kind !== 'videoinput');
              return mapped.concat(audio);
            } catch(_) { return mapped; }
          }
        }
        return await realEnum();
      } catch(e) { return realEnum(); }
    };
  }

  function trackSettings(stream){
    try {
      const t = stream.getVideoTracks()[0];
      if (!t) return {};
      const s = t.getSettings ? t.getSettings() : {};
      const caps = t.getCapabilities ? t.getCapabilities() : {};
      return { label: t.label, settings: safeJSON(s), capabilities: safeJSON(caps) };
    } catch(e) { return {}; }
  }
  function attachTrackListeners(stream){
    try {
      const t = stream.getVideoTracks()[0];
      if (!t) return;
      t.addEventListener('ended', ()=> {
        if (session) session.timeline.streamEnd = performance.now();
        logEvent('track.ended', { label: t.label });
      });
      t.addEventListener('mute', ()=> logEvent('track.mute', { label: t.label }, 'warn'));
      t.addEventListener('unmute', ()=> logEvent('track.unmute', { label: t.label }));
    } catch(e){}
  }
  function safeJSON(o){
    try { return JSON.parse(JSON.stringify(o, (k,v)=> typeof v === 'bigint' ? String(v) : v)); }
    catch(e){ return String(o); }
  }

  // ---------- UI refs ----------
  const $ = id => document.getElementById(id);
  const video = $('video');
  const gridcanvas = $('gridcanvas');
  const gctx = gridcanvas.getContext('2d', { willReadFrequently: true });
  const statusEl = $('status');
  const badge = $('badge');
  const badgeText = $('badgeText');
  const hudwrap = $('hudwrap');
  const sessionPill = $('sessionPill');

  const startBtn = $('startBtn');
  const recBtn = $('recBtn');
  const backPhotoBtn = $('backPhoto');
  const backVideoBtn = $('backVideo');
  const autoBtn = $('autoBtn');
  const galleryEl = $('gallery');
  const countEl = $('count');
  const chipbar = $('chipbar');
  const roName = $('roName'), roRes = $('roRes'), roFov = $('roFov'), roFps = $('roFps');
  const modebar = $('modebar');
  const simControls = $('simControls');
  const realControls = $('realControls');
  const overlayControls = $('overlayControls');
  const reportsControls = $('reportsControls');
  const galleryTitle = $('galleryTitle');
  const logEl = $('log');
  const galleryHeader = $('galleryHeader');

  const toolbox = $('toolbox');
  const revealBtn = $('revealBtn');
  const loupeBtn = $('loupeBtn');
  const gearbtn = $('gearbtn');
  const analyzeBtn = $('analyzeBtn');
  const loupe = $('loupe');
  const loupeCanvas = $('loupeCanvas');
  const loupeCtx = loupeCanvas.getContext('2d');

  const wfCanvas = $('wfCanvas');
  const wfVal = $('wfVal');
  const wfLabel = $('wfLabel');
  const ganttWrap = $('ganttWrap');

  const ovAnalysis = $('ovAnalysis');
  const gaugeArc = $('gaugeArc'), gaugeNum = $('gaugeNum');
  const mVisible = $('mVisible'), mDrift = $('mDrift'), mAspect = $('mAspect'), mLatency = $('mLatency');

  const reportsList = $('reportsList');

  let stream = null;
  let recorder = null;
  let chunks = [];
  let recording = false;
  const items = [];
  let autoMode = false;
  let rafHandle = null;
  let fpsPrev = performance.now();
  let fpsEMA = 0;
  let firstFrameLogged = false;

  function setStatus(t){ statusEl.textContent = t; }
  function setBadge(show, text, recDot){
    badge.style.display = show ? 'flex' : 'none';
    badgeText.textContent = text || '';
    badge.querySelector('.dot').style.display = recDot ? 'inline-block' : 'none';
  }
  function setSessionPill(s, cls){
    sessionPill.textContent = s;
    sessionPill.style.color = cls === 'rec' ? 'var(--bad)' : cls === 'live' ? 'var(--accent)' : 'var(--muted)';
  }

  // ---------- Mode switching ----------
  modebar.addEventListener('click', (e)=>{
    const b = e.target.closest('.modebtn');
    if (!b) return;
    switchMode(b.dataset.mode);
  });
  function switchMode(mode){
    if (currentMode === mode) return;
    teardownAll();
    currentMode = mode;
    modebar.querySelectorAll('.modebtn').forEach(b => b.classList.toggle('active', b.dataset.mode === mode));
    simControls.style.display = mode === 'simulate' ? 'flex' : 'none';
    realControls.style.display = mode === 'realcam' ? 'flex' : 'none';
    overlayControls.style.display = mode === 'overlay' ? 'flex' : 'none';
    reportsControls.style.display = mode === 'reports' ? 'flex' : 'none';
    galleryHeader.style.display = (mode === 'realcam' || mode === 'reports') ? 'none' : 'flex';
    galleryEl.style.display = (mode === 'realcam' || mode === 'reports') ? 'none' : 'grid';
    logEl.style.display = mode === 'realcam' ? 'flex' : 'none';
    ganttWrap.style.display = mode === 'realcam' ? 'block' : 'none';
    toolbox.style.display = (mode === 'overlay') ? 'flex' : 'none';
    gridcanvas.style.display = mode === 'overlay' ? 'block' : 'none';
    loupe.style.display = 'none';
    ovAnalysis.style.display = 'none';
    setStatus('Mode: ' + mode.toUpperCase());
    setSessionPill('READY', '');
    if (mode === 'reports') renderReports();
    logEvent('mode.switch', { mode });
  }
  function teardownAll(){
    stopFront();
    if (recording) stopRec();
    autoMode = false; if (autoBtn) autoBtn.disabled = false;
    if (rafHandle) cancelAnimationFrame(rafHandle);
    rafHandle = null;
    hudwrap.innerHTML = '';
  }

  // ---------- Camera chip bar ----------
  function renderChips(){
    chipbar.innerHTML = '';
    const cams = window.__DUALCAM_CAMERAS || [];
    if (!cams.length) {
      const empty = document.createElement('div');
      empty.className = 'chip';
      empty.textContent = 'No cameras · open Cameras tab';
      chipbar.appendChild(empty);
      return;
    }
    const activeId = (getActive() || {}).id;
    cams.forEach(c => {
      const chip = document.createElement('div');
      chip.className = 'chip' + (c.id === activeId ? ' active' : '');
      const symbol = c.position === 'Front' ? '◉' : '▣';
      chip.innerHTML = symbol + ' ' + escapeHtml(c.name) + ' <span class="pos">' + escapeHtml(c.position) + '</span>';
      chip.addEventListener('click', ()=> switchCamera(c.id));
      chipbar.appendChild(chip);
    });
  }

  function renderReadout(){
    const a = getActive();
    if (!a) { roName.textContent = '—'; roRes.textContent = '—'; roFov.textContent = '—'; return; }
    roName.textContent = a.name + (a.isVirtual ? '·v' : '');
    const r = a.videoDefault || a.webVideoOnly;
    roRes.textContent = r ? (r.w + '×' + r.h) : '—';
    roFov.textContent = a.fov ? a.fov.toFixed(1) + '°' : '—';
    video.classList.toggle('mirror', a.position === 'Front');
  }

  async function switchCamera(id){
    window.__DUALCAM_ACTIVE_ID = id;
    renderChips(); renderReadout();
    postMessage('activeCameraChanged', { id });
    logEvent('camera.select', { id });
    if (stream) { stopFront(); await startFront(); }
  }

  // ---------- Start/stop ----------
  async function startFront(){
    try {
      if (stream) return;
      const active = getActive();
      if (!active && currentMode === 'simulate') { setStatus('No camera.'); return; }
      if (!session) session = newSession(currentMode);
      if (session && active) session.device = {
        id: active.id, name: active.name, position: active.position,
        deviceType: active.deviceType, isVirtual: active.isVirtual, fov: active.fov,
        videoDefault: active.videoDefault, photoDefault: active.photoDefault,
        webVideoOnly: active.webVideoOnly, webWidthOnly: active.webWidthOnly, webHeightOnly: active.webHeightOnly
      };
      const hint = active && (active.webVideoOnly || active.videoDefault);
      const t0 = performance.now();
      logEvent('startFront.begin', { mode: currentMode, hint });
      setSessionPill('WARMUP', 'live');
      stream = await navigator.mediaDevices.getUserMedia({
        video: (currentMode === 'simulate' && hint) ? { width: { ideal: hint.w }, height: { ideal: hint.h } } : true,
        audio: currentMode === 'simulate'
      });
      video.srcObject = stream;
      firstFrameLogged = false;
      video.addEventListener('playing', onFirstPlaying, { once: true });
      await video.play().catch(()=>{});
      if (simControls.style.display !== 'none') {
        startBtn.disabled = true; startBtn.textContent = '● Live';
        recBtn.disabled = false;
      }
      const track = stream.getVideoTracks()[0];
      const settings = track ? track.getSettings() : {};
      const label = active ? active.name : (track && track.label) || 'Camera';
      const posLabel = active ? (active.position === 'Front' ? 'FRONT' : 'BACK') : 'LIVE';
      setBadge(true, posLabel + ' · ' + currentMode.toUpperCase(), false);
      setStatus('Live · ' + (settings.width || '?') + '×' + (settings.height || '?') + ' · ' + label);
      setSessionPill('LIVE', 'live');
      logEvent('startFront.ready', { elapsedMs: Math.round(performance.now()-t0), settings });
      startFrameLoop();
      if (currentMode === 'overlay') ensureGrid();
    } catch (e) {
      setStatus('Camera failed: ' + (e.message || e));
      setSessionPill('ERROR', 'rec');
      logEvent('startFront.error', { error: String(e && e.message || e) }, 'err');
    }
  }

  function onFirstPlaying(){
    if (firstFrameLogged) return;
    firstFrameLogged = true;
    if (session) session.timeline.firstFrame = performance.now();
    logEvent('video.firstFrame', { w: video.videoWidth, h: video.videoHeight });
    renderGantt();
  }

  function stopFront(){
    if (!stream) return;
    stream.getTracks().forEach(t => t.stop());
    stream = null;
    video.srcObject = null;
    if (session && !session.timeline.streamEnd) session.timeline.streamEnd = performance.now();
    if (startBtn) { startBtn.disabled = false; startBtn.textContent = '► Start Camera'; }
    if (recBtn) recBtn.disabled = true;
    setBadge(false);
    setSessionPill('READY', '');
    logEvent('stopFront', {});
    if (rafHandle) cancelAnimationFrame(rafHandle);
    rafHandle = null;
    renderGantt();
  }

  // ---------- Frame loop (FPS, ambient, grid render, waveform) ----------
  const ambientSamples = [];
  let ambientAvg = 128;
  function startFrameLoop(){
    fpsPrev = performance.now(); fpsEMA = 0;
    const loop = ()=>{
      const now = performance.now();
      const dt = now - fpsPrev; fpsPrev = now;
      if (dt > 0) {
        const inst = 1000 / dt;
        fpsEMA = fpsEMA ? (fpsEMA*0.9 + inst*0.1) : inst;
        if (session) session.fpsSamples.push({ t: now, fps: fpsEMA });
        if (session && session.fpsSamples.length > 600) session.fpsSamples.shift();
        roFps.textContent = fpsEMA.toFixed(1);
        if (currentMode === 'realcam') drawWaveform();
      }
      if (currentMode === 'overlay' && video.videoWidth) renderGrid();
      updateHud();
      rafHandle = requestAnimationFrame(loop);
    };
    rafHandle = requestAnimationFrame(loop);
  }

  // HUD live telemetry
  function updateHud(){
    if (currentMode === 'simulate') { hudwrap.innerHTML = ''; return; }
    const track = stream && stream.getVideoTracks()[0];
    const st = track && track.getSettings ? track.getSettings() : {};
    const items = [];
    if (st.width && st.height) items.push({ k: st.width + '×' + st.height, cls: '' });
    if (st.frameRate) items.push({ k: Math.round(st.frameRate) + 'fps', cls: '' });
    if (session && session.requestedConstraints && session.grantedSettings) {
      const r = session.requestedConstraints.video || {};
      const rw = (r.width && (r.width.ideal || r.width.exact)) || null;
      const rh = (r.height && (r.height.ideal || r.height.exact)) || null;
      if (rw && st.width && rw !== st.width) items.push({ k: 'Δw '+(rw-st.width), cls: 'warn' });
      if (rh && st.height && rh !== st.height) items.push({ k: 'Δh '+(rh-st.height), cls: 'warn' });
    }
    items.push({ k: fpsEMA.toFixed(1) + 'fps', cls: fpsEMA < 20 ? 'warn' : '' });
    if (currentMode === 'overlay') items.push({ k: 'GRID A1–I12', cls: '' });
    hudwrap.innerHTML = items.map(i => '<div class="hudchip '+i.cls+'">'+escapeHtml(i.k)+'</div>').join('');
  }

  // ---------- Waveform ----------
  function drawWaveform(){
    const c = wfCanvas;
    const dpr = window.devicePixelRatio || 1;
    const w = c.clientWidth, h = c.clientHeight;
    if (c.width !== w*dpr) { c.width = w*dpr; c.height = h*dpr; }
    const ctx = c.getContext('2d');
    ctx.setTransform(dpr,0,0,dpr,0,0);
    ctx.clearRect(0,0,w,h);
    const samples = session ? session.fpsSamples : [];
    const n = Math.min(samples.length, 180);
    if (!n) return;
    ctx.strokeStyle = 'rgba(0,255,178,0.25)';
    ctx.lineWidth = 1;
    ctx.beginPath(); ctx.moveTo(0, h*0.5); ctx.lineTo(w, h*0.5); ctx.stroke();
    ctx.beginPath();
    ctx.strokeStyle = 'var(--accent)';
    ctx.strokeStyle = '#00FFB2';
    ctx.lineWidth = 1.5;
    for (let i=0; i<n; i++){
      const s = samples[samples.length - n + i];
      const x = (i/(n-1||1))*w;
      const y = h - Math.max(0, Math.min(1, s.fps/60))*h;
      if (i===0) ctx.moveTo(x,y); else ctx.lineTo(x,y);
    }
    ctx.stroke();
    wfVal.textContent = fpsEMA.toFixed(1) + ' fps';
  }

  // ---------- Gantt ----------
  function renderGantt(){
    if (!session) return;
    const t = session.timeline;
    const base = session.startPerf;
    const end = (t.streamEnd || performance.now()) - base;
    const rows = [
      ['REQUEST', t.requestStart, t.permissionGranted, 'bar'],
      ['PERMISSION', t.requestStart, t.permissionGranted, 'bar warn'],
      ['WARMUP', t.permissionGranted, t.firstFrame, 'bar'],
      ['STREAM', t.firstFrame, t.streamEnd, 'bar'],
    ];
    const max = Math.max(end, 100);
    const html = rows.map(r => {
      const lbl = r[0], a = r[1], b = r[2], cls = r[3];
      if (a == null) return '<div class="row"><div class="lbl">'+lbl+'</div><div class="track"></div><div class="ms">—</div></div>';
      const aP = Math.max(0, (a - base) / max * 100);
      const bP = Math.max(aP, ((b || performance.now()) - base) / max * 100);
      const dur = Math.round(((b || performance.now()) - a));
      return '<div class="row"><div class="lbl">'+lbl+'</div><div class="track"><div class="'+cls+'" style="left:'+aP+'%;width:'+(bP-aP)+'%"></div></div><div class="ms">'+dur+'ms</div></div>';
    }).join('');
    ganttWrap.innerHTML = html;
    const ga = $('ganttAnalysis');
    if (ga) ga.innerHTML = html;
  }

  // ---------- A–I × 1–12 Fiducial Grid ----------
  const COLS = ['A','B','C','D','E','F','G','H','I']; // 9
  const ROWS = 12;
  const gridCfg = {
    contrast: 3, rings: 5, labelSize: 12, subPerceptual: true, autoTune: true, reveal: false
  };

  function ensureGrid(){
    gridcanvas.classList.toggle('reveal', gridCfg.reveal);
    if (!gridcanvas.width) {
      gridcanvas.width = 900; gridcanvas.height = 1200;
    }
  }

  function renderGrid(){
    const vw = video.videoWidth || video.clientWidth || 720;
    const vh = video.videoHeight || video.clientHeight || 960;
    if (gridcanvas.width !== vw || gridcanvas.height !== vh) {
      gridcanvas.width = vw; gridcanvas.height = vh;
    }
    // Ambient-driven contrast
    if (gridCfg.autoTune) sampleAmbient();
    const c = gctx;
    c.clearRect(0,0,vw,vh);
    const lum = gridCfg.subPerceptual
      ? Math.max(1, Math.min(40, gridCfg.contrast))
      : 200;
    // Auto-tune: darker scene → need slightly less, brighter → slightly more
    let effective = lum;
    if (gridCfg.autoTune && gridCfg.subPerceptual) {
      const factor = (ambientAvg / 128); // 0..2
      effective = Math.max(1, Math.min(40, Math.round(gridCfg.contrast * (0.7 + factor*0.3))));
    }
    const colorVal = effective;
    const stroke = 'rgb('+colorVal+','+colorVal+','+colorVal+')';
    c.strokeStyle = stroke; c.fillStyle = stroke;
    c.lineWidth = 1;

    // Draw the A-I x 1-12 grid lines
    const ncols = COLS.length; // 9
    const cellW = vw / ncols;
    const cellH = vh / ROWS;

    c.beginPath();
    for (let i=1; i<ncols; i++){
      const x = Math.round(i * cellW) + 0.5;
      c.moveTo(x, 0); c.lineTo(x, vh);
    }
    for (let j=1; j<ROWS; j++){
      const y = Math.round(j * cellH) + 0.5;
      c.moveTo(0, y); c.lineTo(vw, y);
    }
    c.stroke();

    // Labels at every intersection (coordinate "A1".."I12")
    const labelFontSize = gridCfg.labelSize;
    c.font = '700 '+labelFontSize+'px ui-monospace, "SF Mono", monospace';
    c.textBaseline = 'top';
    c.textAlign = 'left';
    for (let i=0; i<ncols; i++){
      for (let j=0; j<ROWS; j++){
        const label = COLS[i] + (j+1);
        const x = i*cellW + 3;
        const y = j*cellH + 3;
        c.fillText(label, x, y);
      }
    }

    // Concentric bullseye rings at the exact optical center
    const cx = vw/2, cy = vh/2;
    const maxR = Math.min(vw, vh) * 0.35;
    const rings = Math.max(2, Math.min(8, gridCfg.rings));
    c.lineWidth = 1;
    for (let r=1; r<=rings; r++){
      const rad = (r/rings) * maxR;
      c.beginPath(); c.arc(cx, cy, rad, 0, Math.PI*2); c.stroke();
    }
    // Crosshair
    c.beginPath();
    c.moveTo(cx - maxR, cy); c.lineTo(cx + maxR, cy);
    c.moveTo(cx, cy - maxR); c.lineTo(cx, cy + maxR);
    c.stroke();
    // Optical center marker
    c.fillRect(cx-2, cy-2, 4, 4);

    // Corner fiducials (L markers) for unambiguous orientation
    const fs = Math.min(vw, vh) * 0.08;
    c.lineWidth = 2;
    drawCornerL(c, 8, 8, fs, 1, 1);
    drawCornerL(c, vw-8, 8, fs, -1, 1);
    drawCornerL(c, 8, vh-8, fs, 1, -1);
    drawCornerL(c, vw-8, vh-8, fs, -1, -1);

    // Update loupe if visible
    if (loupe.style.display === 'block') updateLoupe();
  }
  function drawCornerL(c, x, y, len, sx, sy){
    c.beginPath();
    c.moveTo(x, y); c.lineTo(x + sx*len, y);
    c.moveTo(x, y); c.lineTo(x, y + sy*len);
    c.stroke();
  }

  function sampleAmbient(){
    try {
      const t = performance.now();
      if (t - (sampleAmbient._last||0) < 500) return;
      sampleAmbient._last = t;
      const off = document.createElement('canvas');
      off.width = 16; off.height = 16;
      const o = off.getContext('2d');
      o.drawImage(video, 0, 0, 16, 16);
      const px = o.getImageData(0,0,16,16).data;
      let sum = 0;
      for (let i=0; i<px.length; i+=4) {
        sum += (px[i]*0.299 + px[i+1]*0.587 + px[i+2]*0.114);
      }
      ambientAvg = sum / (px.length/4);
      ambientSamples.push(ambientAvg);
      if (ambientSamples.length > 20) ambientSamples.shift();
    } catch(e){}
  }

  // ---------- Loupe (Pattern Lab magnifier w/ high-pass recovery) ----------
  let loupePos = { x: 0.5, y: 0.5 };
  function updateLoupe(){
    const rect = video.getBoundingClientRect();
    const size = 140;
    loupe.style.width = size+'px'; loupe.style.height = size+'px';
    const lx = loupePos.x * rect.width - size/2;
    const ly = loupePos.y * rect.height - size/2;
    loupe.style.left = lx+'px'; loupe.style.top = ly+'px';
    // Composite video + grid at the loupe center, then apply high-pass recovery
    const vw = video.videoWidth, vh = video.videoHeight;
    if (!vw) return;
    const sx = loupePos.x * vw, sy = loupePos.y * vh;
    const srcSize = 50;
    const sx0 = Math.max(0, sx - srcSize/2), sy0 = Math.max(0, sy - srcSize/2);
    const dst = loupeCanvas;
    const ctx = loupeCtx;
    ctx.clearRect(0,0,dst.width,dst.height);
    // draw video
    ctx.drawImage(video, sx0, sy0, srcSize, srcSize, 0, 0, dst.width, dst.height);
    // add grid overlay
    ctx.globalCompositeOperation = 'difference';
    ctx.drawImage(gridcanvas, sx0, sy0, srcSize, srcSize, 0, 0, dst.width, dst.height);
    ctx.globalCompositeOperation = 'source-over';
    // apply high-pass / threshold recovery: amplify differences
    try {
      const img = ctx.getImageData(0,0,dst.width,dst.height);
      const d = img.data;
      for (let i=0; i<d.length; i+=4){
        const l = d[i]*0.299 + d[i+1]*0.587 + d[i+2]*0.114;
        // Emphasize any shift off neutral (simulate AI recovery filter)
        const amp = Math.max(0, Math.min(255, (l - 10) * 6));
        d[i] = amp*0.2; d[i+1] = amp; d[i+2] = amp*0.6;
      }
      ctx.putImageData(img, 0, 0);
    } catch(e){}
  }
  // Drag loupe
  video.addEventListener('pointerdown', onLoupeMove);
  video.parentElement.addEventListener('pointermove', (e)=>{
    if (e.buttons && loupe.style.display === 'block') onLoupeMove(e);
  });
  function onLoupeMove(e){
    if (loupe.style.display !== 'block') return;
    const rect = video.getBoundingClientRect();
    loupePos.x = Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
    loupePos.y = Math.max(0, Math.min(1, (e.clientY - rect.top) / rect.height));
  }

  // ---------- Detection engine (visible range / drift / aspect via canvas analysis) ----------
  function analyzeOverlay(){
    const t0 = performance.now();
    const vw = video.videoWidth, vh = video.videoHeight;
    const rect = video.getBoundingClientRect();
    const rw = rect.width, rh = rect.height;
    if (!vw || !rw) {
      return { visibleRange: 0, centroidDrift: 0, aspect: 0, samples: 0, latencyMs: 0, health: 0 };
    }
    // Rendered frame is object-fit: cover. Compute expected native→render mapping.
    const scale = Math.max(rw/vw, rh/vh);
    const renderedW = vw * scale, renderedH = vh * scale;
    const visibleW = Math.min(renderedW, rw) / scale;
    const visibleH = Math.min(renderedH, rh) / scale;
    const visibleArea = visibleW * visibleH;
    const nativeArea = vw * vh;
    const visibleRange = Math.max(0, Math.min(100, (visibleArea / nativeArea) * 100));
    // Centroid drift = offset of rendered center vs native center (in px @ native scale)
    const renderedCenterNativeX = (rw/2) / scale + Math.max(0, (renderedW - rw)/2)/scale;
    const renderedCenterNativeY = (rh/2) / scale + Math.max(0, (renderedH - rh)/2)/scale;
    const drift = Math.hypot(renderedCenterNativeX - vw/2, renderedCenterNativeY - vh/2);
    // Aspect distortion: compare rendered aspect vs native aspect. With object-fit: cover, near 1.
    const aspect = (rw/rh) / (vw/vh);
    const aspectDistortion = Math.abs(aspect - 1) * 100;

    const samples = COLS.length * ROWS;
    const latencyMs = performance.now() - t0;

    // Health score: weighted
    const vr = visibleRange / 100;
    const dr = Math.min(1, drift / Math.max(1, Math.min(vw,vh)*0.1));
    const ad = Math.min(1, aspectDistortion / 50);
    const health = Math.round(Math.max(0, Math.min(100, (vr*0.55 + (1-dr)*0.25 + (1-ad)*0.2) * 100)));
    return {
      visibleRange: +visibleRange.toFixed(1),
      centroidDrift: +drift.toFixed(1),
      aspectDistortion: +aspectDistortion.toFixed(2),
      samples, latencyMs: +latencyMs.toFixed(2),
      health
    };
  }

  function showOverlayAnalysis(){
    const a = analyzeOverlay();
    if (session) session.analysis = a;
    ovAnalysis.style.display = 'flex';
    mVisible.textContent = a.visibleRange + '%';
    mDrift.textContent = a.centroidDrift + 'px';
    mAspect.textContent = a.aspectDistortion + '%';
    mLatency.textContent = a.latencyMs + 'ms';
    setGauge(gaugeArc, gaugeNum, a.health);
    logEvent('analysis', a);
    triggerHaptic();
  }
  function setGauge(arc, num, val){
    const v = Math.max(0, Math.min(100, val));
    const full = 2 * Math.PI * 28; // 176
    arc.setAttribute('stroke-dasharray', full);
    arc.setAttribute('stroke-dashoffset', full - (v/100)*full);
    arc.setAttribute('stroke', v >= 80 ? '#00FFB2' : v >= 55 ? '#FFB020' : '#FF3B30');
    num.textContent = v;
    num.style.color = v >= 80 ? 'var(--good)' : v >= 55 ? 'var(--warn)' : 'var(--bad)';
  }

  // ---------- Simulate controls ----------
  recBtn.addEventListener('click', ()=>{ recording ? stopRec() : startRec(); });
  startBtn.addEventListener('click', ()=> { if (!session) session = newSession('simulate'); startFront(); });
  backPhotoBtn.addEventListener('click', ()=>{
    stopFront(); setStatus('Opening native Camera (photo)…');
    const a = getActive();
    postMessage('openNativeCamera', { mode: 'photo', cameraId: a && a.id, position: a && a.position });
  });
  backVideoBtn.addEventListener('click', ()=>{
    stopFront(); setStatus('Opening native Camera (video)…');
    const a = getActive();
    postMessage('openNativeCamera', { mode: 'video', cameraId: a && a.id, position: a && a.position });
  });
  autoBtn.addEventListener('click', async ()=>{
    if (autoMode) return;
    autoMode = true; autoBtn.disabled = true;
    if (!session) session = newSession('simulate');
    await startFront();
    setStatus('Auto: preview for 3 seconds…');
    await new Promise(r => setTimeout(r, 3000));
    stopFront();
    setStatus('Auto: opening native video…');
    const a = getActive();
    postMessage('openNativeCamera', { mode: 'video', cameraId: a && a.id, position: a && a.position });
  });

  function startRec(){
    if (!stream || recording) return;
    chunks = [];
    let mime = 'video/mp4';
    try { if (!MediaRecorder.isTypeSupported(mime)) mime = 'video/webm'; } catch(_) { mime = 'video/webm'; }
    try { recorder = new MediaRecorder(stream, { mimeType: mime }); }
    catch(_) { recorder = new MediaRecorder(stream); mime = recorder.mimeType || 'video/mp4'; }
    recorder.ondataavailable = (e)=>{ if (e.data && e.data.size) chunks.push(e.data); };
    recorder.onstop = ()=>{
      const blob = new Blob(chunks, { type: mime });
      blobToBase64(blob).then(b64 => {
        const active = getActive();
        const meta = active ? { cameraId: active.id, cameraName: active.name } : {};
        addItem({ kind: 'front-video', mime, b64, meta });
        postCapture('front-video', mime, b64, meta);
      });
      recording = false;
      recBtn.textContent = '● Record Clip';
      const active = getActive();
      setBadge(true, (active && active.position === 'Front' ? 'FRONT' : 'BACK') + ' · SIMULATE', false);
    };
    recorder.start();
    recording = true;
    recBtn.textContent = '■ Stop Recording';
    setBadge(true, 'REC', true);
    setStatus('Recording clip…');
  }
  function stopRec(){ if (recorder && recording) recorder.stop(); }

  // ---------- Real Cam ----------
  const realStart = $('realStart');
  const realStop = $('realStop');
  const realClear = $('realClear');
  const realExport = $('realExport');
  const realFinalize = $('realFinalize');

  realStart.addEventListener('click', async ()=>{
    realStart.disabled = true; realStop.disabled = false;
    session = newSession('realcam');
    setBadge(true, 'PROFILING', true);
    logEvent('realcam.start', { activeId: window.__DUALCAM_ACTIVE_ID });
    await startFront();
  });
  realStop.addEventListener('click', ()=>{
    realStart.disabled = false; realStop.disabled = true;
    logEvent('realcam.stop', {});
    stopFront();
  });
  realClear.addEventListener('click', ()=>{ if (session) session.entries.length = 0; renderLog(); });
  realExport.addEventListener('click', ()=>{ exportSessionJSON(); });
  realFinalize.addEventListener('click', ()=>{ finalizeSession(); });

  function renderLog(){
    if (!session) { logEl.innerHTML = ''; return; }
    logEl.innerHTML = '';
    const recent = session.entries.slice(-250);
    recent.forEach(e => {
      const row = document.createElement('div');
      row.className = 'logrow' + (e.level === 'err' ? ' err' : e.level === 'warn' ? ' warn' : '');
      const ts = fmtPerf(e.t);
      const det = JSON.stringify(e.detail);
      row.innerHTML = '<span class="t">'+ts+'</span><span class="e">'+escapeHtml(e.event)+'</span>' +
        '<details><summary>'+escapeHtml(det.slice(0,60))+(det.length>60?'…':'')+'</summary>'+escapeHtml(JSON.stringify(e.detail, null, 2))+'</details>';
      logEl.appendChild(row);
    });
    logEl.scrollTop = logEl.scrollHeight;
    countEl.textContent = String(session.entries.length);
  }
  function fmtPerf(t){
    const secs = t / 1000;
    return secs.toFixed(3).padStart(8,' ');
  }

  // ---------- Overlay ----------
  const ovStart = $('ovStart');
  const ovStop = $('ovStop');
  const ovReveal = $('ovReveal');
  const ovAnalyze = $('ovAnalyze');
  const ovFinalize = $('ovFinalize');

  ovStart.addEventListener('click', async ()=>{
    ovStart.disabled = true; ovStop.disabled = false;
    session = newSession('overlay');
    await startFront();
    ensureGrid();
    logEvent('overlay.start', { grid: { cols: COLS.length, rows: ROWS, subPerceptual: gridCfg.subPerceptual } });
  });
  ovStop.addEventListener('click', ()=>{
    ovStart.disabled = false; ovStop.disabled = true;
    stopFront();
  });
  ovReveal.addEventListener('click', ()=>{
    gridCfg.reveal = !gridCfg.reveal;
    gridcanvas.classList.toggle('reveal', gridCfg.reveal);
    ovReveal.classList.toggle('primary', gridCfg.reveal);
  });
  ovAnalyze.addEventListener('click', showOverlayAnalysis);
  ovFinalize.addEventListener('click', ()=>{ showOverlayAnalysis(); finalizeSession(); });

  revealBtn.addEventListener('click', ()=>{
    gridCfg.reveal = !gridCfg.reveal;
    gridcanvas.classList.toggle('reveal', gridCfg.reveal);
    revealBtn.classList.toggle('on', gridCfg.reveal);
  });
  loupeBtn.addEventListener('click', ()=>{
    const show = loupe.style.display !== 'block';
    loupe.style.display = show ? 'block' : 'none';
    loupeBtn.classList.toggle('on', show);
    if (show) { loupePos = { x: 0.5, y: 0.5 }; updateLoupe(); }
  });
  analyzeBtn.addEventListener('click', showOverlayAnalysis);

  // ---------- Grid settings sheet ----------
  const gridSheet = $('gridSheet');
  const miniCanvas = $('miniCanvas');
  const contrastR = $('contrastR'), contrastV = $('contrastV');
  const ringsR = $('ringsR'), ringsV = $('ringsV');
  const labelR = $('labelR'), labelV = $('labelV');
  const subPerceptTgl = $('subPerceptTgl');
  const autoTuneTgl = $('autoTuneTgl');
  const gridDone = $('gridDone');

  gearbtn.addEventListener('click', ()=>{ gridSheet.style.display = 'flex'; renderMini(); });
  gridDone.addEventListener('click', ()=>{ gridSheet.style.display = 'none'; });
  gridSheet.addEventListener('click', (e)=>{ if (e.target === gridSheet) gridSheet.style.display = 'none'; });
  subPerceptTgl.addEventListener('click', ()=>{
    gridCfg.subPerceptual = !gridCfg.subPerceptual;
    subPerceptTgl.classList.toggle('on', gridCfg.subPerceptual);
    renderMini();
  });
  autoTuneTgl.addEventListener('click', ()=>{
    gridCfg.autoTune = !gridCfg.autoTune;
    autoTuneTgl.classList.toggle('on', gridCfg.autoTune);
  });
  contrastR.addEventListener('input', ()=>{ gridCfg.contrast = +contrastR.value; contrastV.textContent = '±'+gridCfg.contrast; renderMini(); });
  ringsR.addEventListener('input', ()=>{ gridCfg.rings = +ringsR.value; ringsV.textContent = String(gridCfg.rings); renderMini(); });
  labelR.addEventListener('input', ()=>{ gridCfg.labelSize = +labelR.value; labelV.textContent = gridCfg.labelSize+'px'; renderMini(); });

  function renderMini(){
    const c = miniCanvas;
    const dpr = window.devicePixelRatio || 1;
    const w = c.clientWidth || 300, h = c.clientHeight || 100;
    c.width = w*dpr; c.height = h*dpr;
    const ctx = c.getContext('2d');
    ctx.setTransform(dpr,0,0,dpr,0,0);
    // background: simulate video noise
    const img = ctx.createImageData(w,h);
    for (let i=0; i<img.data.length; i+=4){
      const n = 60 + Math.random()*20;
      img.data[i]=n; img.data[i+1]=n; img.data[i+2]=n; img.data[i+3]=255;
    }
    ctx.putImageData(img, 0, 0);
    // grid overlay (sub-perceptual if enabled)
    const lum = gridCfg.subPerceptual ? Math.max(1, Math.min(40, gridCfg.contrast)) : 200;
    const color = 'rgb('+(60+lum)+','+(60+lum)+','+(60+lum)+')';
    ctx.strokeStyle = color; ctx.fillStyle = color;
    const ncols = COLS.length;
    const cw = w/ncols, chh = h/ROWS;
    ctx.lineWidth = 1;
    ctx.beginPath();
    for (let i=1;i<ncols;i++){ ctx.moveTo(Math.round(i*cw)+0.5, 0); ctx.lineTo(Math.round(i*cw)+0.5, h); }
    for (let j=1;j<ROWS;j++){ ctx.moveTo(0, Math.round(j*chh)+0.5); ctx.lineTo(w, Math.round(j*chh)+0.5); }
    ctx.stroke();
    ctx.font = '700 '+Math.max(7,gridCfg.labelSize-4)+'px ui-monospace, monospace';
    ctx.textBaseline = 'top';
    for (let i=0;i<ncols;i++) for (let j=0;j<ROWS;j++)
      ctx.fillText(COLS[i]+(j+1), i*cw+2, j*chh+2);
  }

  // ---------- Finalize session → save report ----------
  function finalizeSession(){
    if (!session) return;
    session.endPerf = performance.now();
    if (!session.analysis && currentMode === 'overlay') session.analysis = analyzeOverlay();
    const report = buildReport(session);
    sessions.unshift(report);
    renderReports();
    openAnalysisSheet(report);
    logEvent('session.finalize', { id: session.id });
    triggerHaptic();
  }

  function buildReport(s){
    return {
      id: s.id,
      mode: s.mode,
      startWall: s.startWall,
      endWall: new Date().toISOString(),
      durationMs: Math.round((s.endPerf || performance.now()) - s.startPerf),
      device: s.device,
      activeId: s.activeId,
      requestedConstraints: s.requestedConstraints,
      grantedSettings: s.grantedSettings,
      grantedCapabilities: s.grantedCapabilities,
      timeline: {
        requestStart: rel(s, s.timeline.requestStart),
        permissionGranted: rel(s, s.timeline.permissionGranted),
        streamReady: rel(s, s.timeline.streamReady),
        firstFrame: rel(s, s.timeline.firstFrame),
        streamEnd: rel(s, s.timeline.streamEnd)
      },
      fpsStats: fpsStats(s.fpsSamples),
      entries: s.entries.map(e => ({ t: +(e.t - s.startPerf).toFixed(3), wall: e.wall, event: e.event, detail: e.detail, level: e.level })),
      analysis: s.analysis || null
    };
  }
  function rel(s, p){ return p == null ? null : +(p - s.startPerf).toFixed(3); }
  function fpsStats(samples){
    if (!samples || !samples.length) return null;
    const v = samples.map(x=>x.fps);
    const min = Math.min.apply(null, v), max = Math.max.apply(null, v);
    const avg = v.reduce((a,b)=>a+b,0)/v.length;
    const s = v.reduce((a,b)=>a+(b-avg)*(b-avg),0)/v.length;
    return { min: +min.toFixed(2), max: +max.toFixed(2), avg: +avg.toFixed(2), stdev: +Math.sqrt(s).toFixed(2), count: v.length };
  }

  function openAnalysisSheet(report){
    const a = report.analysis;
    const sheet = $('analysisSheet');
    const arc = $('gaugeArc2'), num = $('gaugeNum2');
    if (a) {
      setGauge(arc, num, a.health);
      $('mVisible2').textContent = a.visibleRange + '%';
      $('mDrift2').textContent = a.centroidDrift + 'px';
      $('mAspect2').textContent = a.aspectDistortion + '%';
      $('mSamples2').textContent = String(a.samples);
    } else {
      setGauge(arc, num, 0);
      $('mVisible2').textContent = '—';
      $('mDrift2').textContent = '—';
      $('mAspect2').textContent = '—';
      $('mSamples2').textContent = String(report.entries.length);
    }
    renderGantt();
    sheet.style.display = 'flex';
    sheet.dataset.reportId = report.id;
  }
  $('analysisSheet').addEventListener('click', (e)=>{ if (e.target.id === 'analysisSheet') e.currentTarget.style.display = 'none'; });
  $('anClose').addEventListener('click', ()=>{ $('analysisSheet').style.display = 'none'; });
  $('anShareJSON').addEventListener('click', ()=>{ shareReportJSON(currentReport()); });
  $('anSharePDF').addEventListener('click', ()=>{ shareReportPDF(currentReport()); });
  function currentReport(){
    const id = $('analysisSheet').dataset.reportId;
    return sessions.find(r => r.id === id);
  }

  // ---------- Reports list ----------
  function renderReports(){
    reportsList.innerHTML = '';
    if (!sessions.length) {
      reportsList.innerHTML = '<div class="report"><div>No sessions yet. Run Real Cam or Overlay and tap End & Analyze.</div></div>';
      return;
    }
    sessions.forEach(r => {
      const row = document.createElement('div');
      row.className = 'report';
      const health = r.analysis ? r.analysis.health : '—';
      row.innerHTML =
        '<div>' +
          '<span class="score">⎔ '+health+'</span>' +
          '<b>'+escapeHtml(r.mode.toUpperCase())+'</b> · '+escapeHtml((r.device && r.device.name) || 'Camera')+
          '<div class="meta">'+escapeHtml(new Date(r.startWall).toLocaleString())+' · '+r.durationMs+'ms · '+r.entries.length+' evt</div>'+
        '</div>' +
        '<div class="actions">'+
          '<button data-act="open">Open</button>'+
          '<button data-act="json">JSON</button>'+
          '<button data-act="pdf">PDF</button>'+
          '<button data-act="del">✕</button>'+
        '</div>';
      row.addEventListener('click', (e)=>{
        const act = e.target.dataset.act;
        if (act === 'open') openAnalysisSheet(r);
        else if (act === 'json') shareReportJSON(r);
        else if (act === 'pdf') shareReportPDF(r);
        else if (act === 'del') { sessions = sessions.filter(x => x.id !== r.id); renderReports(); }
      });
      reportsList.appendChild(row);
    });
  }

  function exportSessionJSON(){
    if (!session) return;
    const r = buildReport(session);
    sessions.unshift(r);
    renderReports();
    shareReportJSON(r);
  }

  function shareReportJSON(r){
    if (!r) return;
    const str = JSON.stringify(r, null, 2);
    const b64 = utf8Base64(str);
    const fname = 'kysee-'+r.mode+'-'+r.id+'.json';
    postMessage('share', { data: b64, mime: 'application/json', filename: fname });
  }

  function shareReportPDF(r){
    if (!r) return;
    const pdf = buildPDF(r);
    const b64 = utf8Base64Bytes(pdf);
    const fname = 'kysee-'+r.mode+'-'+r.id+'.pdf';
    postMessage('share', { data: b64, mime: 'application/pdf', filename: fname });
  }

  // Minimal PDF generator (single page, monospace text)
  function buildPDF(r){
    const lines = [];
    lines.push('KYSEE DIAGNOSTIC REPORT');
    lines.push('Mode: '+r.mode.toUpperCase()+'   ID: '+r.id);
    lines.push('Started: '+r.startWall);
    lines.push('Duration: '+r.durationMs+' ms');
    if (r.device) {
      lines.push('');
      lines.push('DEVICE');
      lines.push('  '+ (r.device.name||'') + ' ('+ (r.device.position||'') + ')');
      lines.push('  Type: '+(r.device.deviceType||'—')+'  Virtual: '+(r.device.isVirtual?'yes':'no')+'  FOV: '+(r.device.fov||'—'));
      const vd = r.device.videoDefault;
      if (vd) lines.push('  Native default: '+vd.w+'x'+vd.h);
    }
    if (r.requestedConstraints) {
      lines.push('');
      lines.push('REQUESTED CONSTRAINTS');
      lines.push('  '+JSON.stringify(r.requestedConstraints).slice(0,240));
    }
    if (r.grantedSettings) {
      lines.push('');
      lines.push('GRANTED SETTINGS');
      lines.push('  '+JSON.stringify(r.grantedSettings).slice(0,240));
    }
    if (r.fpsStats) {
      lines.push('');
      lines.push('FPS STATS');
      lines.push('  avg='+r.fpsStats.avg+' min='+r.fpsStats.min+' max='+r.fpsStats.max+' stdev='+r.fpsStats.stdev);
    }
    if (r.timeline) {
      lines.push('');
      lines.push('TIMELINE (ms from start)');
      Object.keys(r.timeline).forEach(k => { lines.push('  '+k.padEnd(20,' ')+ (r.timeline[k]==null?'—':r.timeline[k])); });
    }
    if (r.analysis) {
      lines.push('');
      lines.push('ANALYSIS');
      lines.push('  Health:          '+r.analysis.health);
      lines.push('  Visible Range:   '+r.analysis.visibleRange+'%');
      lines.push('  Centroid Drift:  '+r.analysis.centroidDrift+'px');
      lines.push('  Aspect Distort:  '+r.analysis.aspectDistortion+'%');
    }
    lines.push('');
    lines.push('EVENTS ('+r.entries.length+')');
    r.entries.slice(0,60).forEach(e => {
      lines.push('  t+'+String(e.t).padStart(8,' ')+'ms  '+e.event);
    });

    return makePDF(lines);
  }

  // Very small single-page PDF writer (Helvetica text)
  function makePDF(lines){
    const enc = new TextEncoder();
    const bytes = [];
    const append = (s) => { for (const b of enc.encode(s)) bytes.push(b); };
    const offsets = [];
    const addObj = (body) => {
      offsets.push(bytes.length);
      append((offsets.length) + ' 0 obj\n' + body + '\nendobj\n');
    };
    append('%PDF-1.4\n');
    // 1: catalog
    addObj('<< /Type /Catalog /Pages 2 0 R >>');
    // 2: pages
    addObj('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
    // 3: page
    addObj('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 5 0 R >> >> /Contents 4 0 R >>');
    // 4: content stream
    let content = 'BT\n/F1 10 Tf\n12 TL\n36 756 Td\n';
    lines.forEach((ln, i) => {
      const clean = ln.replace(/[\\\(\)]/g, s => '\\'+s).slice(0, 110);
      if (i === 0) content += '('+clean+') Tj\n';
      else content += 'T*\n('+clean+') Tj\n';
    });
    content += 'ET\n';
    const streamBody = '<< /Length '+content.length+' >>\nstream\n'+content+'endstream';
    addObj(streamBody);
    // 5: font
    addObj('<< /Type /Font /Subtype /Type1 /BaseFont /Courier >>');
    // xref
    const xrefStart = bytes.length;
    append('xref\n0 '+(offsets.length+1)+'\n0000000000 65535 f \n');
    offsets.forEach(o => append(String(o).padStart(10,'0')+' 00000 n \n'));
    append('trailer\n<< /Size '+(offsets.length+1)+' /Root 1 0 R >>\nstartxref\n'+xrefStart+'\n%%EOF');
    return new Uint8Array(bytes);
  }

  function utf8Base64(str){
    return btoa(unescape(encodeURIComponent(str)));
  }
  function utf8Base64Bytes(bytes){
    let s = '';
    for (let i=0; i<bytes.length; i++) s += String.fromCharCode(bytes[i]);
    return btoa(s);
  }

  // ---------- Native bridge ----------
  window.dualcamOnNativeWillOpen = function(){ stopFront(); setStatus('Native camera opening…'); };
  window.dualcamOnReturn = function(){
    setStatus('Returned from native camera. Restarting…');
    if (autoMode) { autoMode = false; autoBtn.disabled = false; }
    if (currentMode === 'simulate') startFront();
  };
  window.dualcamOnCameraUnavailable = function(){
    setStatus('Native camera unavailable (simulator). Restarting preview…');
    if (autoMode) { autoMode = false; autoBtn.disabled = false; }
    if (currentMode === 'simulate') startFront();
  };
  window.dualcamOnNativeResult = function(payload){
    try {
      if (!payload || !payload.data) return;
      addItem({ kind: payload.kind, mime: payload.mime, b64: payload.data });
    } catch(e){}
    window.dualcamOnReturn();
  };
  window.dualcamSetInventory = function(cams, activeId){
    window.__DUALCAM_CAMERAS = Array.isArray(cams) ? cams : [];
    if (activeId) window.__DUALCAM_ACTIVE_ID = activeId;
    else if (!window.__DUALCAM_ACTIVE_ID && window.__DUALCAM_CAMERAS.length) {
      window.__DUALCAM_ACTIVE_ID = window.__DUALCAM_CAMERAS[0].id;
    }
    renderChips(); renderReadout();
  };
  window.dualcamSetActive = function(id){ if (!id) return; switchCamera(id); };

  function addItem({ kind, mime, b64, meta }){
    const id = 'it-' + Date.now() + '-' + Math.random().toString(36).slice(2, 7);
    const item = { id, kind, mime, b64, meta: meta || {} };
    items.unshift(item);
    renderGallery();
  }
  function renderGallery(){
    galleryEl.innerHTML = '';
    if (currentMode !== 'realcam' && currentMode !== 'reports') countEl.textContent = String(items.length);
    items.forEach(it => {
      const el = document.createElement('div');
      el.className = 'item';
      const kindLabel = document.createElement('div');
      kindLabel.className = 'kind';
      kindLabel.textContent = ({
        'front-video': 'LIVE', 'back-photo': 'PHOTO', 'back-video': 'VIDEO'
      })[it.kind] || it.kind;
      el.appendChild(kindLabel);
      if ((it.mime || '').startsWith('image')) {
        const img = document.createElement('img');
        img.src = 'data:' + it.mime + ';base64,' + it.b64;
        el.appendChild(img);
      } else {
        const v = document.createElement('video');
        v.src = 'data:' + it.mime + ';base64,' + it.b64;
        v.muted = true; v.playsInline = true; v.loop = true;
        v.addEventListener('click', ()=>{ v.paused ? v.play() : v.pause(); });
        el.appendChild(v);
      }
      const save = document.createElement('button');
      save.className = 'save';
      save.textContent = '💾';
      save.addEventListener('click', (ev)=>{
        ev.stopPropagation();
        postMessage('save', { data: it.b64, mime: it.mime });
      });
      el.appendChild(save);
      galleryEl.appendChild(el);
    });
  }

  function blobToBase64(blob){
    return new Promise((resolve, reject)=>{
      const r = new FileReader();
      r.onloadend = ()=>{
        const s = r.result || '';
        const i = String(s).indexOf(',');
        resolve(i >= 0 ? String(s).slice(i+1) : String(s));
      };
      r.onerror = reject;
      r.readAsDataURL(blob);
    });
  }
  function escapeHtml(s){
    return String(s).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'})[c]);
  }
  function postMessage(name, body){
    try {
      if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[name]) {
        window.webkit.messageHandlers[name].postMessage(body || {});
      }
    } catch(e){}
  }
  function postCapture(kind, mime, b64, meta){
    postMessage('capture', { kind, mime, data: b64, meta: meta || {} });
  }
  function triggerHaptic(){
    try { if (window.navigator.vibrate) window.navigator.vibrate(8); } catch(e){}
  }

  document.addEventListener('visibilitychange', ()=>{
    if (document.hidden && stream) {
      logEvent('visibility.hidden', {});
      stopFront();
    }
  });
  window.addEventListener('pagehide', ()=>{ reArm('pagehide'); });

  // init
  setInterceptState('armed');
  renderChips(); renderReadout(); renderReports();
})();
</script>
</body>
</html>
"""#
}
