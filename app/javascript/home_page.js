$(document).ready(function() {

  $(document).on('ajax:success', 'form', function(event,data) {
    if (data.user) {
       var fullName;
       if (data.user.last_name) {
         fullName = data.user.first_name + ' ' + data.user.last_name;
       } else {
         fullName = data.user.first_name;
       }
    $('.profileName').text(fullName)
    alert('User updated successfully!');
  }
  }).on('ajax:error', 'form', function(event, data) {

    let errors;
    if (data.responseJSON) {
        // If the response is already in JSON format
        errors = JSON.parse(data.responseJSON.errors);
    } else if (data.responseText) {
        // If the response is a JSON string
        const response = JSON.parse(data.responseText);
        errors = JSON.parse(response.errors);
    } else {
        alert('Failed to update user. Please try again.');
        return;
    }

    const formattedErrors = errors.map((error, index) => `${index + 1}. ${error}`).join("\n");
    alert(`Failed to update user. Please try again.\n\n${formattedErrors}`);
  });

  $(document).on('show.bs.modal', '#invitePlayer', function (event) {
     var button = $(event.relatedTarget); // Button that triggered the modal
     var playerType = button.data('player-type'); // Extract player_type attribute from the button
     // Set the value of the hidden field based on playerType
     $('#playerTypeField').val(playerType);
   });

  // profile picture upload
  $(document).on('change', '#file-upload', function() {
    var file = this.files[0];
    if (file) {
      var formData = new FormData();
      var csrfToken = $('meta[name=csrf-token]').attr('content');
      formData.append('image', file);
      $.ajax({
        url: '/add_profile_picture',
        type: 'PUT',
        data: formData,
        processData: false,
        contentType: false,
        headers: { 'X-CSRF-Token': csrfToken },
        success: function(response) {
          // Handle success response
          console.log('Image uploaded successfully');
          // If you want to update the image after successful upload, you can do it here
          $('#profile-container').load('/users/edit #profile-container > *');
          $('#profile-image').attr('src', response.image_url);
        },
        error: function(xhr, status, error) {
          // Handle error
          alert('Error uploading image:', error);
        }
      });
    }
  });

  $(document).on('click', '.edit', function(e) {
    $('#player_email').val('');
    var email = $(this).data('player-email');
    $("#player_email_display").val(email)
    $("#player_email").val(email)
  });

  $('.cancel-btn').click(function(e) {
    e.preventDefault();
    $.ajax({
      url: $(this).attr('href'),
      method: 'GET',
      dataType: 'html',
      success: function(data) {
        $('#edit-form-container').html(data);
      },
      error: function(xhr, status, error) {
        console.error('Failed to reload edit form:', error);
      }
    });
  });
});