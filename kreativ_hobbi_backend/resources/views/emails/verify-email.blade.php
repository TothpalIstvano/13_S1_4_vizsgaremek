<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Email megerősítés</title>
  <link href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    body {
      font-family: 'Rubik', sans-serif;
      background: linear-gradient(135deg, #ff8a65b8 0%, #632a17cf 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 40px 20px;
    }

    /* Szövúrős háttér réteg */
    body::before {
      content: '';
      position: fixed;
      inset: 0;
      background-image: url('https://texturelabs.org/wp-content/uploads/Texturelabs_Fabric_155thumbnail.jpg');
      background-size: cover;
      background-position: center;
      opacity: 0.12;
      z-index: 0;
    }

    .email-wrapper {
      position: relative;
      z-index: 1;
      width: 100%;
      max-width: 580px;
    }

    /* Kártya - neumorphism */
    .card {
      background-color: #ecf0f3;
      border-radius: 24px;
      padding: 50px 48px;
      box-shadow:
        10px 10px 20px #c9d0db,
        -10px -10px 20px #f9f9f9;
      text-align: center;
    }

    /* Logo / ikon terület */
    .brand-icon {
      width: 72px;
      height: 72px;
      margin: 0 auto 24px;
      background: linear-gradient(135deg, #ff8a65 0%, #632a17 100%);
      border-radius: 20px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 34px;
      box-shadow:
        4px 4px 10px #d1d9e6,
        -4px -4px 10px #f9f9f9;
    }

    /* Cím */
    h1 {
      font-size: 1.85rem;
      font-weight: 800;
      color: #3d1a0e;
      margin-bottom: 10px;
      letter-spacing: -0.5px;
    }

    h1 span {
      background: linear-gradient(90deg, #914f04 0%, #ff6800 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    /* Elválasztó - a site-ról jön */
    .divider {
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 20px 0 24px;
    }

    .divider-line {
      flex: 1;
      height: 3px;
      background: linear-gradient(90deg, transparent, #cbd5e0, transparent);
      border-radius: 2px;
    }

    .divider-dot {
      width: 8px;
      height: 8px;
      background: #ad6801;
      border-radius: 50%;
      margin: 0 14px;
      box-shadow: 0 0 0 4px rgba(173, 104, 1, 0.15);
    }

    /* Üdvözlés */
    .greeting {
      font-size: 1.05rem;
      font-weight: 500;
      color: #5a3020;
      margin-bottom: 14px;
    }

    /* Szövegtörzs */
    p {
      font-size: 0.95rem;
      line-height: 1.7;
      color: #7a5040;
      margin-bottom: 32px;
    }

    /* Gomb - neumorphism + gradient */
    .btn-wrapper {
      margin-bottom: 32px;
    }

    .btn {
      display: inline-block;
      padding: 16px 44px;
      background: linear-gradient(135deg, #ff8a65 0%, #6f3826 100%);
      color: white;
      text-decoration: none;
      border-radius: 50px;
      font-size: 1rem;
      font-weight: 700;
      letter-spacing: 0.5px;
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      box-shadow:
        4px 4px 12px rgba(111, 56, 38, 0.35),
        -2px -2px 8px rgba(255, 255, 255, 0.5);
    }

    /* Kézi URL (ha gomb nem működik) */
    .manual-url {
      background-color: #ecf0f3;
      border-radius: 12px;
      padding: 14px 20px;
      margin-bottom: 28px;
      box-shadow:
        inset 2px 2px 5px #d1d9e6,
        inset -2px -2px 5px #f9f9f9;
    }

    .manual-url p {
      font-size: 0.8rem;
      color: #8b5e3c;
      margin-bottom: 8px;
    }

    .manual-url a {
      font-size: 0.75rem;
      color: #6f3826;
      word-break: break-all;
      text-decoration: none;
      font-weight: 500;
      border-bottom: 1px solid #8b040430;
      line-height: 1.8;
    }

    /* Elválasztó vonal */
    .footer-divider {
      height: 2px;
      background: linear-gradient(90deg, transparent, #d1c0b8, transparent);
      border-radius: 2px;
      margin: 8px 0 24px;
    }

    /* Lábléc szöveg */
    .footer-note {
      font-size: 0.82rem;
      color: #a07060;
      line-height: 1.6;
      margin-bottom: 0;
    }

    /* Felső gradient csík a kártyán */
    .card::before {
      content: '';
      display: block;
      height: 4px;
      background: linear-gradient(135deg, #ff6a00, #680000);
      border-radius: 20px 20px 0 0;
      margin: -50px -48px 40px;
    }
  </style>
</head>
<body>
  <div class="email-wrapper">
    <div class="card">

      <!-- Ikon -->
      <div class="brand-icon">🧵</div>

      <!-- Cím -->
      <h1>Erősítsd meg<br><span>email címed!</span></h1>

      <!-- Elválasztó -->
      <div class="divider">
        <div class="divider-line"></div>
        <div class="divider-dot"></div>
        <div class="divider-line"></div>
      </div>

      <!-- Üdvözlés és szöveg -->
      <p class="greeting">Helló, {{ $user->felhasz_nev }}! 👋</p>
      <p>
        Köszönjük, hogy csatlakoztál hozzánk! Már csak egy lépés választ el attól,
        hogy teljes hozzáférést kapj fiókodhoz és prémium tartalmainhoz.
        Kattints az alábbi gombra az email cím megerősítéséhez.
      </p>

      <!-- Gomb -->
      <div class="btn-wrapper">
        <a href="{{ $url }}" class="btn">Email megerősítése →</a>
      </div>

      <!-- Manuális URL -->
      <div class="manual-url">
        <p>Ha a gomb nem működik, másold be ezt a linket a böngésződbe:</p>
        <a href="{{ $url }}">{{ $url }}</a>
      </div>

      <div class="footer-divider"></div>

      <!-- Lábléc -->
      <p class="footer-note">
        Ez a link <strong>60 percig</strong> érvényes.<br>
        Ha nem te regisztráltál, hagyd figyelmen kívül ezt az emailt — fiókod biztonságban van.
      </p>

    </div>
  </div>
</body>
</html>