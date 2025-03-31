$(document).ready(function() {
  // Check if invitation_id is present in the URL parameters
  const urlParams = new URLSearchParams(window.location.search);
  const invitationId = urlParams.get('invitation_id');
  // If invitation_id is present, autofill the email field
  if (invitationId) {
    $.ajax({
      url: '/get_email',
      type: 'GET',
      data: { invite_id: invitationId },
      dataType: 'json',
      success: function(data) {
        const inviteeEmail = data.email;
        $('.emailInput').val(inviteeEmail);
      },
      error: function(xhr, status, error) {
        console.error('Error fetching invitee email:', error);
      }
    });
  }
});