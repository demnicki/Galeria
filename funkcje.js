/* Funkcja AJAX callback usuwająca plik / wiersz z tebli "Pliki". */
function usunPlik(id) {
    apex.server.process('Usun_plik',
        {
            x01: id
        },
        {
            success: function(pData) {
                apex.message.showPageSuccess('Plik ' + pData.nazwa + 'został usunięty.');
            },

            error: function(e) {
                     apex.message.showPageSuccess('Coś poszło nie tak. Kod błędu: ' + e);
            }
        }
    );
}

/* Akcja dynamiczna dla obiektu załadowania pliku we formularzu "Dodaj plik". */
apex.item('?_NAZWA').setValue(apex.item('?_PLIK').getValue());