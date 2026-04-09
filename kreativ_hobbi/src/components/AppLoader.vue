<style scoped>
  .spinner-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 3rem 1rem;
    gap: 1.5rem;
  }
  .spinner-label {
    font-size: 20px;
    color: var(--color-text-secondary);
    letter-spacing: 0.04em;
  }
  .dots span {
    animation: blink 1.4s infinite both;
    font-size: 30px;
    color: var(--color-text-secondary);
  }
  .dots span:nth-child(2) { animation-delay: 0.2s; }
  .dots span:nth-child(3) { animation-delay: 0.4s; }
  @keyframes blink {
    0%, 80%, 100% { opacity: 0.2; }
    40% { opacity: 1; }
  }
  @keyframes spin-yarn {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  @keyframes needle-bob {
    0%, 100% { transform: translateY(0px) rotate(-20deg); }
    50% { transform: translateY(-6px) rotate(-20deg); }
  }
  @keyframes needle-bob2 {
    0%, 100% { transform: translateY(0px) rotate(20deg); }
    50% { transform: translateY(6px) rotate(20deg); }
  }
  @keyframes loop-draw {
    0% { stroke-dashoffset: 300; }
    100% { stroke-dashoffset: 0; }
  }
  @keyframes yarn-spin {
    from { transform: rotate(0deg); }
    to { transform: rotate(360deg); }
  }
  .yarn-ball-group {
    animation: yarn-spin 2.4s linear infinite;
    transform-origin: 60px 60px;
  }
  .needle-left {
    animation: needle-bob 1.2s ease-in-out infinite;
    transform-origin: 50% 80%;
  }
  .needle-right {
    animation: needle-bob2 1.2s ease-in-out infinite;
    transform-origin: 50% 80%;
  }
  .yarn-loop {
    stroke-dasharray: 300;
    animation: loop-draw 2.4s linear infinite;
  }
</style>
<template>
<div class="spinner-wrap">
  <svg width="120" height="120" viewBox="0 0 120 120" role="img">
    <title>Kötögetős töltő animáció</title>

    <g class="yarn-ball-group">
      <circle cx="60" cy="60" r="32" fill="#D85A30" opacity="0.15"/>
      <circle cx="60" cy="60" r="32" fill="none" stroke="#D85A30" stroke-width="2.5" opacity="0.5"/>
      <path d="M32 54 Q60 30 88 60" fill="none" stroke="#D85A30" stroke-width="2" stroke-linecap="round" opacity="0.7"/>
      <path d="M34 66 Q60 90 86 60" fill="none" stroke="#D85A30" stroke-width="2" stroke-linecap="round" opacity="0.7"/>
      <path d="M46 31 Q40 60 50 89" fill="none" stroke="#993C1D" stroke-width="1.5" stroke-linecap="round" opacity="0.5"/>
      <path d="M74 31 Q80 60 70 89" fill="none" stroke="#993C1D" stroke-width="1.5" stroke-linecap="round" opacity="0.5"/>
      <circle cx="60" cy="60" r="32" fill="none" stroke="#BA7517" stroke-width="1" stroke-dasharray="5 4" opacity="0.4"/>
    </g>

    <g class="needle-left" style="transform-origin: 38px 96px;">
      <rect x="36" y="28" width="4" height="68" rx="2" fill="#5F5E5A"/>
      <ellipse cx="38" cy="27" rx="3" ry="5" fill="#888780"/>
      <rect x="36.5" y="32" width="3" height="4" rx="1" fill="#B4B2A9"/>
    </g>

    <g class="needle-right" style="transform-origin: 82px 96px;">
      <rect x="80" y="28" width="4" height="68" rx="2" fill="#5F5E5A"/>
      <ellipse cx="82" cy="27" rx="3" ry="5" fill="#888780"/>
      <rect x="80.5" y="32" width="3" height="4" rx="1" fill="#B4B2A9"/>
    </g>

    <path class="yarn-loop"
      d="M38 50 Q44 38 60 36 Q76 34 82 50"
      fill="none" stroke="#D85A30" stroke-width="2.5" stroke-linecap="round"/>
  </svg>

  <div style="display:flex; flex-direction:column; align-items:center; gap:4px;">
    <span class="spinner-label">Töltés folyamatban</span>
    <span class="dots"><span>•</span><span>•</span><span>•</span></span>
  </div>
</div>
</template>