<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>{{ config('app.name') }}</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="color-scheme" content="light">
<meta name="supported-color-schemes" content="light">
<link href="https://fonts.googleapis.com/css2?family=Rubik:wght@300;400;500;600;700;800&display=swap" rel="stylesheet"/>
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: 'Rubik', sans-serif !important;
  background: linear-gradient(135deg, #ff8a65b8 0%, #632a17cf 100%) !important;
  padding: 40px 20px !important;
}

.wrapper {
  background: linear-gradient(135deg, #ff8a65b8 0%, #632a17cf 100%);
  width: 100% !important;
}

.content {
  width: 100% !important;
}

.inner-body {
  background-color: #ecf0f3 !important;
  border-radius: 24px !important;
  box-shadow: 10px 10px 20px #c9d0db, -10px -10px 20px #f9f9f9 !important;
  width: 570px !important;
}

.content-cell {
  padding: 48px !important;
  text-align: center !important;
  font-family: 'Rubik', sans-serif !important;
}

/* Felső gradient csík */
.header {
  background: linear-gradient(135deg, #ff6a00, #680000) !important;
  border-radius: 24px 24px 0 0 !important;
  height: 6px !important;
  width: 100% !important;
}

h1 {
  font-size: 1.6rem !important;
  font-weight: 800 !important;
  color: #3d1a0e !important;
  margin-bottom: 16px !important;
}

p {
  font-size: 0.95rem !important;
  line-height: 1.7 !important;
  color: #7a5040 !important;
  margin-bottom: 24px !important;
}

/* Gomb */
.button {
  background: linear-gradient(135deg, #ff8a65 0%, #6f3826 100%) !important;
  border-radius: 50px !important;
  color: white !important;
  font-family: 'Rubik', sans-serif !important;
  font-size: 1rem !important;
  font-weight: 700 !important;
  padding: 14px 40px !important;
  text-decoration: none !important;
  box-shadow: 4px 4px 12px rgba(111, 56, 38, 0.35) !important;
}

/* Subcopy (manuális link) */
.subcopy {
  background-color: #ecf0f3 !important;
  border-radius: 12px !important;
  padding: 14px 20px !important;
  box-shadow: inset 2px 2px 5px #d1d9e6, inset -2px -2px 5px #f9f9f9 !important;
  font-size: 0.78rem !important;
  color: #8b5e3c !important;
}

.subcopy a {
  color: #6f3826 !important;
}

/* Lábléc */
.footer {
  text-align: center !important;
  padding: 20px !important;
}

.footer p {
  font-size: 0.8rem !important;
  color: #a07060 !important;
}

@media only screen and (max-width: 600px) {
  .inner-body { width: 100% !important; }
  .footer { width: 100% !important; }
}
@media only screen and (max-width: 500px) {
  .button { width: 100% !important; }
}
</style>
{!! $head ?? '' !!}
</head>
<body>

<table class="wrapper" width="100%" cellpadding="0" cellspacing="0" role="presentation">
<tr>
<td align="center">
<table class="content" width="100%" cellpadding="0" cellspacing="0" role="presentation">

<!-- Felső csík -->

{!! $header ?? '' !!}

<tr>
<td class="body" width="100%" cellpadding="0" cellspacing="0" style="border: hidden !important;">
<table class="inner-body" align="center" width="570" cellpadding="0" cellspacing="0" role="presentation">
<tr>
<td class="content-cell">
{!! Illuminate\Mail\Markdown::parse($slot) !!}
{!! $subcopy ?? '' !!}
</td>
</tr>
</table>
</td>
</tr>

{!! $footer ?? '' !!}
</table>
</td>
</tr>
</table>
</body>
</html>