import "rails_admin/src/rails_admin/base";

$(document).on('click', '.success.btn-outline-success', function(event) {
    fetchTeams(true);
});

$(document).on('click', '.danger.btn-outline-danger.default.btn-outline-secondary', function(event) {
    fetchTeams(false);
});

function fetchTeams(winners) {
    $.ajax({
        url: '/teams/winner_teams',
        method: 'GET',
        data: { winners: winners },
        success: function(response) {
            const selectElement = $('.form-control.ra-multiselect-collection');
            selectElement.empty();

            // Iterate over each team in the response and create an option element
            response.forEach(function(team) {
                selectElement.append(`<option value="${team.id}">${team.name}</option>`);
            });
        },
        error: function(xhr, status, error) {
            // Handle error response here
            console.error('Error fetching teams:', error);
        }
    });
}
