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
                <th>Létrehozás</th>
                <th>Müveletek</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($felhasznalok as $felhasznalo)
            <tr>
                <td>{{ $felhasznalo->id }}</td>
                <td>{{ $felhasznalo->family->surname ?? 'Nincs adat' }}</td>
                <td>{{ $felhasznalo->name }}</td>
                <td>{{ $felhasznalo->created_at }}</td>
                <td><a href="#" class="btn btn-sn btn-danger btn-delete-name" data-id="{{ $felhasznalo->id }}">Törlés</a></td>
            </tr>
            @endforeach
        </tbody>
    </table>
</body>
<script>
        $(".btn-delete-name").on('click', function(){
            let thisBtn = $(this);
            let id = thisBtn.data('id');
            $.ajax({
                type: "POST",
                url: "/names/delete",
                data: {
                    _token: "{{ csrf_token() }}",
                    id: id,
                },
                success: function(){
                    thisBtn.closest('tr').fadeOut();
                },
                error: function(){ 
                        alert('Hiba a törlés során!');
                    }
                });
            });
    </script>
<style>

</style>
</html>