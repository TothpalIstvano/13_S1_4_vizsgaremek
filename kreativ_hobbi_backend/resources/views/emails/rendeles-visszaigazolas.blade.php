<!DOCTYPE html>
<html lang="hu" xmlns="http://www.w3.org/1999/xhtml">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>Rendelés visszaigazolás</title>
  <style>
    @import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=DM+Serif+Display&display=swap');

    body, table, td, p, a { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
    table, td { mso-table-lspace: 0pt; mso-table-rspace: 0pt; }
    img { border: 0; height: auto; line-height: 100%; outline: none; text-decoration: none; }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', Arial, sans-serif;
      background: #0f0f0f;
      color: #1a1a1a;
      padding: 40px 16px;
    }

    .outer {
      max-width: 640px;
      margin: 0 auto;
    }

    /* ── TOP LABEL ── */
    .top-label {
      text-align: center;
      font-size: 11px;
      font-weight: 600;
      letter-spacing: 3px;
      text-transform: uppercase;
      color: #c47a4a;
      margin-bottom: 20px;
    }

    /* ── CARD ── */
    .card {
      background: #ffffff;
      border-radius: 20px;
      overflow: hidden;
      box-shadow: 0 32px 80px rgba(0,0,0,0.45);
    }

    /* ── HERO ── */
    .hero {
      background: linear-gradient(145deg, #1a0a00 0%, #3d1a0a 40%, #6b2d12 70%, #b55b3f 100%);
      padding: 52px 40px 44px;
      position: relative;
      overflow: hidden;
    }
    .hero::before {
      content: '';
      position: absolute;
      top: -60px; right: -60px;
      width: 260px; height: 260px;
      background: radial-gradient(circle, rgba(181,91,63,0.35) 0%, transparent 70%);
      border-radius: 50%;
    }
    .hero::after {
      content: '';
      position: absolute;
      bottom: -80px; left: -40px;
      width: 200px; height: 200px;
      background: radial-gradient(circle, rgba(255,180,100,0.12) 0%, transparent 70%);
      border-radius: 50%;
    }
    .hero-inner { position: relative; z-index: 1; }
    .hero-icon {
      width: 64px; height: 64px;
      background: rgba(255,255,255,0.12);
      border: 1px solid rgba(255,255,255,0.2);
      border-radius: 16px;
      display: inline-flex;
      align-items: center;
      justify-content: center;
      font-size: 30px;
      margin-bottom: 20px;
    }
    .hero h1 {
      font-family: 'DM Serif Display', Georgia, serif;
      font-size: 32px;
      font-weight: 400;
      color: #ffffff;
      line-height: 1.2;
      margin-bottom: 10px;
      width: 2em;
    }
    .hero p {
      font-size: 15px;
      color: rgba(255,255,255,0.7);
      line-height: 1.6;
      max-width: 380px;
    }
    .order-pill {
      display: inline-block;
      margin-top: 20px;
      background: rgba(255,255,255,0.1);
      border: 1px solid rgba(255,255,255,0.2);
      border-radius: 999px;
      padding: 6px 18px;
      font-size: 13px;
      font-weight: 600;
      color: #ffc49a;
      letter-spacing: 0.5px;
    }

    /* ── BODY ── */
    .body {
      padding: 40px 40px 32px;
    }

    .greeting {
      font-size: 17px;
      color: #1a1a1a;
      margin-bottom: 8px;
      font-weight: 500;
    }
    .intro {
      font-size: 14px;
      color: #777;
      line-height: 1.7;
      margin-bottom: 36px;
    }

    /* ── INFO CARDS ── */
    .info-grid {
      display: table;
      width: 100%;
      margin-bottom: 32px;
      border-spacing: 0;
    }
    .info-grid-row {
      display: table-row;
    }
    .info-grid-cell {
      display: table-cell;
      width: 50%;
      padding: 0 8px 16px 0;
      vertical-align: top;
    }
    .info-grid-cell:last-child { padding-right: 0; }

    .mini-card {
      background: #faf9f7;
      border: 1px solid #ede9e3;
      border-radius: 12px;
      padding: 16px 18px;
    }
    .mini-card-label {
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 1.5px;
      text-transform: uppercase;
      color: #b55b3f;
      margin-bottom: 6px;
    }
    .mini-card-value {
      font-size: 14px;
      font-weight: 600;
      color: #1a1a1a;
      line-height: 1.4;
    }
    .mini-card-value.muted {
      font-weight: 400;
      color: #555;
    }

    /* STATUS */
    .status-fizetve  { color: #057a55; }
    .status-fuggoben { color: #92400e; }
    .status-sikertelen { color: #991b1b; }

    /* ── SECTION HEADING ── */
    .section-heading {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 16px;
      margin-top: 8px;
    }
    .section-heading-line {
      flex: 1;
      height: 1px;
      background: linear-gradient(90deg, #e5e0d8, transparent);
    }
    .section-heading-text {
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 2px;
      text-transform: uppercase;
      color: #aaa;
      white-space: nowrap;
    }

    /* ── DELIVERY BLOCK ── */
    .delivery-block {
      background: linear-gradient(135deg, #fdf8f5, #fff9f5);
      border: 1px solid #f0e8de;
      border-radius: 14px;
      padding: 20px 22px;
      margin-bottom: 32px;
    }
    .delivery-row {
      display: flex;
      justify-content: space-between;
      padding: 6px 0;
      font-size: 14px;
      border-bottom: 1px dashed #f0ebe3;
    }
    .delivery-row:last-child { border-bottom: none; }
    .dl { color: #999; font-size: 13px; }
    .dv { font-weight: 500; color: #1a1a1a; text-align: right; max-width: 60%; }

    /* ── ITEMS TABLE ── */
    .items-wrap {
      border: 1px solid #ede9e3;
      border-radius: 14px;
      overflow: hidden;
      margin-bottom: 0;
    }
    .items-table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }
    .items-table thead tr {
      background: linear-gradient(90deg, #faf7f4, #f7f2ed);
    }
    .items-table th {
      padding: 12px 16px;
      text-align: left;
      font-size: 10px;
      font-weight: 700;
      letter-spacing: 1.2px;
      text-transform: uppercase;
      color: #b55b3f;
    }
    .items-table th.r, .items-table td.r { text-align: right; }
    .items-table th.c, .items-table td.c { text-align: center; }
    .items-table td {
      padding: 14px 16px;
      border-top: 1px solid #f2ede6;
      color: #333;
    }
    .items-table td.product-name {
      font-weight: 500;
    }
    .items-table td.product-name::before {
      content: '·';
      color: #b55b3f;
      margin-right: 8px;
      font-size: 18px;
      line-height: 0;
      vertical-align: middle;
    }
    .qty-badge {
      display: inline-block;
      background: #ffebd3;
      color: #a8532b;
      font-size: 12px;
      font-weight: 700;
      padding: 2px 10px;
      border-radius: 999px;
    }
    .total-row {
      background: linear-gradient(135deg, #b55b3f, #81442f);
    }
    .total-row td {
      padding: 16px 16px;
      font-weight: 700;
      font-size: 15px;
      color: #fff !important;
      border-top: none;
    }
    .total-row td.r {
      font-size: 18px;
      letter-spacing: -0.3px;
    }

    /* ── FOOTER ── */
    .footer {
      background: #0f0f0f;
      padding: 28px 40px;
      text-align: center;
    }
    .footer-logo {
      font-family: 'DM Serif Display', Georgia, serif;
      font-size: 20px;
      color: #c47a4a;
      margin-bottom: 10px;
      letter-spacing: 0.5px;
    }
    .footer p {
      font-size: 12px;
      color: #555;
      line-height: 1.7;
    }
    .footer a {
      color: #b55b3f;
      text-decoration: none;
    }

    /* ── BOTTOM STRIP ── */
    .bottom-strip {
      height: 4px;
      background: linear-gradient(90deg, #b55b3f, #f0a070, #b55b3f);
      background-size: 200% 100%;
    }

    @media (max-width: 480px) {
      body { padding: 20px 10px; }
      .hero { padding: 36px 24px 32px; }
      .hero h1 { font-size: 26px; }
      .body { padding: 28px 24px 24px; }
      .footer { padding: 24px; }
      .info-grid, .info-grid-row, .info-grid-cell {
        display: block;
        width: 100%;
        padding-right: 0;
      }
      .info-grid-cell { margin-bottom: 10px; }
    }
  </style>
</head>
<body>
  <div class="outer">

    <p class="top-label">Kreatív Hobbi · Rendelés visszaigazolás</p>

    <div class="card">

      <!-- HERO -->
      <div class="hero">
        <div class="hero-inner">
          <div class="hero-icon">🎁</div>
          <h1>Rendelésed<br>megkaptuk!</h1>
          <p>Köszönjük a vásárlást. Hamarosan feldolgozzuk rendelésedet és értesítünk a szállítás állapotáról.</p>
          <div class="order-pill">Rendelésszám: #{{ $rendeles['id'] }}</div>
        </div>
      </div>

      <!-- BODY -->
      <div class="body">

        <p class="greeting">Kedves <strong>{{ $rendeles['szallitasi_nev'] }}</strong>!</p>
        <p class="intro">
          Az alábbi rendelés sikeresen rögzítve lett rendszerünkben.
          Amint feldolgozzuk, értesítünk a szállítás aktuális állapotáról.
        </p>

        <!-- INFO MINI CARDS -->
        <div class="info-grid">
          <div class="info-grid-row">
            <div class="info-grid-cell">
              <div class="mini-card">
                <div class="mini-card-label">Dátum</div>
                <div class="mini-card-value muted">
                  {{ \Carbon\Carbon::parse($rendeles['rendeles_datuma'])->format('Y. m. d. H:i') }}
                </div>
              </div>
            </div>
            <div class="info-grid-cell">
              <div class="mini-card">
                <div class="mini-card-label">Fizetési státusz</div>
                <div class="mini-card-value
                  @if($rendeles['fizetes_statusz'] === 'fizetve') status-fizetve
                  @elseif($rendeles['fizetes_statusz'] === 'sikertelen') status-sikertelen
                  @else status-fuggoben @endif">
                  @if($rendeles['fizetes_statusz'] === 'fizetve') ✓ Fizetve
                  @elseif($rendeles['fizetes_statusz'] === 'sikertelen') ✗ Sikertelen
                  @else ⏳ Függőben @endif
                </div>
              </div>
            </div>
          </div>
          <div class="info-grid-row">
            <div class="info-grid-cell">
              <div class="mini-card">
                <div class="mini-card-label">Rendelés státusza</div>
                <div class="mini-card-value muted">{{ ucfirst($rendeles['statusz']) }}</div>
              </div>
            </div>
            <div class="info-grid-cell">
              <div class="mini-card">
                <div class="mini-card-label">Végösszeg</div>
                <div class="mini-card-value" style="color:#b55b3f;">
                  {{ number_format($rendeles['osszeg'], 0, ',', ' ') }} Ft
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- SZÁLLÍTÁSI ADATOK -->
        <div class="section-heading">
          <span class="section-heading-text">Szállítási adatok</span>
          <span class="section-heading-line"></span>
        </div>

        <div class="delivery-block">
          <div class="delivery-row">
            <span class="dl">Név</span>
            <span class="dv">{{ $rendeles['szallitasi_nev'] }}</span>
          </div>
          <div class="delivery-row">
            <span class="dl">Email</span>
            <span class="dv">{{ $rendeles['szallitasi_email'] }}</span>
          </div>
          <div class="delivery-row">
            <span class="dl">Telefon</span>
            <span class="dv">{{ $rendeles['szallitasi_telefon'] }}</span>
          </div>
          <div class="delivery-row">
            <span class="dl">Cím</span>
            <span class="dv">{{ $rendeles['szallitasi_varos_nev'] }}, {{ $rendeles['szallitasi_cim'] }}</span>
          </div>
        </div>

        <!-- TERMÉKEK -->
        <div class="section-heading">
          <span class="section-heading-text">Rendelt termékek</span>
          <span class="section-heading-line"></span>
        </div>

        <div class="items-wrap">
          <table class="items-table">
            <thead>
              <tr>
                <th>Termék</th>
                <th class="c">Db</th>
                <th class="r">Egységár</th>
                <th class="r">Összeg</th>
              </tr>
            </thead>
            <tbody>
              @foreach($tetelek as $tetel)
              <tr>
                <td class="product-name">{{ $tetel['nev'] }}</td>
                <td class="c"><span class="qty-badge">{{ $tetel['mennyiseg'] }}</span></td>
                <td class="r" style="color:#777;">{{ number_format($tetel['egysegar'], 0, ',', ' ') }} Ft</td>
                <td class="r" style="font-weight:600;">{{ number_format($tetel['egysegar'] * $tetel['mennyiseg'], 0, ',', ' ') }} Ft</td>
              </tr>
              @endforeach
            </tbody>
            <tfoot>
              <tr class="total-row">
                <td colspan="3">Végösszeg</td>
                <td class="r">{{ number_format($rendeles['osszeg'], 0, ',', ' ') }} Ft</td>
              </tr>
            </tfoot>
          </table>
        </div>

      </div>

      <!-- BOTTOM STRIP -->
      <div class="bottom-strip"></div>

      <!-- FOOTER -->
      <div class="footer">
        <div class="footer-logo">Kreatív Hobbi</div>
        <p>Ez egy automatikus visszaigazoló levél – kérjük, ne válaszolj erre az üzenetre.</p>
        <p style="margin-top:6px;">© {{ date('Y') }} <strong style="color:#444;">{{ config('app.name', 'Kreatív Hobbi') }}</strong> – Minden jog fenntartva.</p>
      </div>

    </div>

  </div>
</body>
</html>