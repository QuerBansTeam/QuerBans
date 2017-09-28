$('#bidButton{{ banId }}').on('hidden.bs.popover shown.bs.popover', function (event) {
    if (event.type === 'hidden') {
        $('#bidButton{{ banId }}').html('Show');
    } else {
        $('#bidButton{{ banId }}').html('Hide');
    }
});
$('#editModal{{ banId }}').on('show.bs.modal', function () {
    var reasonRequired = true;

    {# Disable save/ban button when reason for editing is empty #}
    if(reasonRequired && $('#editReasonEditModal{{ banId }}').val().length === 0) {
        $('#saveButton{{ banId }}').prop('disabled', true);
        $('#banButton{{ banId }}').prop('disabled', true);
    }
});

$('[id$=EditModal{{ banId }}]').on('input focusin focusout', function() {
    validateForm({{ banId }});
});

$('[id$=Modal{{ banId }}]').on('show.bs.modal', function () {
    $('#bidButton{{ banId }}').popover('hide');
});
