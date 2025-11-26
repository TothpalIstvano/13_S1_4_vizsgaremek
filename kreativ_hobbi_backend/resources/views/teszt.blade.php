<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <div class="container">
    <table class="table table-striped table-hover">
        <thead>
            <tr>
                <th>Azonosító</th>
                <th>Név</th>
                <th>Email</th>
                <th>Jelszó</th>
                <th>Profilkép ID</th>
                <th>Státusz</th>
                <th>Létrehozás</th>
            </tr>
        </thead>
        <tbody>
            @php
              $per_page = 10;
              $current_page = (isset($_GET['page'])) ? (int)$_GET['page'] : 1;
              $start = ($current_page - 1) * $per_page;
              $end = $start + $per_page;
              $felhasznalok_to_display = $felhasznalok->slice($start, $per_page);
            @endphp

            @foreach ($felhasznalok_to_display as $felhasznalo)
            <tr>
                <td>{{ $felhasznalo->id }}</td>
                <td>{{ $felhasznalo->felhasz_nev }}</td>
                <td>{{ $felhasznalo->email }}</td>
                <td>{{ $felhasznalo->jelszo }}</td>
                <td>{{ $felhasznalo->profilKep_id }}</td>
                <td>{{ $felhasznalo->statusz }}</td>
                <td>{{ $felhasznalo->created_at }}</td>
            </tr>
            @endforeach           
              @if (count($felhasznalok) > $per_page)
                <tr>
                  <td colspan="7">
                    <div class="d-flex justify-content-center">
                        @if ($current_page * $per_page < count($felhasznalok))
                            <a href="{{ request()->url() }}?page={{ $current_page + 1 }}" class="btn btn-primary" style="float: right;">Következő 10</a>
                        @endif
                        @if ($current_page > 1)
                          <a href="{{ request()->url() }}?page={{ $current_page - 1 }}" class="btn btn-primary" style="float: left;">Előző 10</a>
                        @endif
                    </div>
                  </td>
                </tr>
              @endif
        </tbody>
    </table>
    </div>
</body>
<style>
/* Layout */
.container {
  max-width: 1200px;
  margin: 2rem auto;
  padding: 1rem;
  font-family: system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue",
    Arial, "Noto Sans", "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
  color: #222;
}

/* Responsive table wrapper */
.table {
  width: 100%;
  border-collapse: collapse;
  background: #ffffff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 8px 20px rgba(16, 24, 40, 0.06);
}

/* Head */
.table thead {
  background: linear-gradient(90deg, #faf7f3, #fff);
}
.table thead th {
  font-weight: 700;
  font-size: 14px;
  color: #2b3a4a;
  padding: 14px 16px;
  text-align: left;
  border-bottom: 1px solid rgba(34,34,34,0.06);
}

/* Body rows */
.table tbody td {
  padding: 12px 16px;
  vertical-align: middle;
  font-size: 14px;
  border-bottom: 1px solid rgba(34,34,34,0.04);
  color: #333;
}

/* Hover and zebra */
.table tbody tr:hover td {
  background: #fcfbf9;
}
.table tbody tr:nth-child(odd) td {
  background: #fff;
}
.table tbody tr:nth-child(even) td {
  background: #fafafa;
}

/* Profile image cell (profilKep column) */
.profile-thumb {
  width: 56px;
  height: 56px;
  display: inline-block;
  border-radius: 8px;
  object-fit: cover;
  box-shadow: 0 4px 10px rgba(16,24,40,0.06);
  border: 1px solid rgba(0,0,0,0.04);
}

/* Small screen adjustments */
@media (max-width: 900px) {
  .container { padding: .5rem; margin: 1rem; }
  .table thead th { padding: 10px 8px; font-size: 13px; }
  .table tbody td { padding: 10px 8px; font-size: 13px; }
  .profile-thumb { width: 44px; height: 44px; }
  .table { font-size: 13px; }
  /* allow horizontal scroll on very small screens */
  .container > .table {
    display: block;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
  }
}

/* Utility */
.status-active { color: #0f8a5f; font-weight: 600; }
.status-inactive { color: #9b1b1b; font-weight: 600; }
</style>
</html>