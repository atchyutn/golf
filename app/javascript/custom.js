$(document).ready(function() {
  function getParameterByName(name, url = window.location.href) {
    name = name.replace(/[\[\]]/g, '\\$&');
    let regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, ' '));
  }

  let matchId = getParameterByName('id');

  // Initialize the hole slider
  var sliderContainer = document.getElementById('slider-container');

  if (sliderContainer) {
      var initialSlide = sliderContainer.getAttribute('data-initial-slide');
  }

  $(".holeSlider").slick({
    dots: false,
    infinite: true,
    speed: 300,
    slidesToShow: 9,
    slidesToScroll: 1,
    centerMode: true,
    variableWidth: true,
    initialSlide: (parseInt(initialSlide, 10) - 1),
    prevArrow:
      '<button type="button" class="slick-prev"><i class="bx bx-arrow-back" ></i></button>',
    nextArrow:
      '<button type="button" class="slick-next"><i class="bx bx-right-arrow-alt"></i></button>'
  });

  const currentHoleNumberInput = document.getElementById("current-hole-number");
  const submitButton = document.querySelector(".submit-score-card");

  $(document).on('click', '.slick-arrow', function(event) {
    let initialHoleNumber = $('.holeSlider').slick('slickCurrentSlide') + 1;
    fetchScores(initialHoleNumber);
    $("#current-hole-number").val(initialHoleNumber).trigger('input');  // Trigger 'input' event
  });

  $(document).on('click', '.submit-score-card', function(event) {
    let initialHoleNumber = $('.holeSlider').slick('slickCurrentSlide') + 1;
    $("#current-hole-number").val(initialHoleNumber).trigger('input');  // Trigger 'input' event

    if ($('#current-hole-number').data('total-holes') < parseInt(currentHoleNumberInput.value.trim())) {
      event.preventDefault();
      alert("Please select a hole.");
    }
  });

  // Initialize the tournaments slider
  $(".tournamentsWrap").slick({
    dots: false,
    infinite: false,
    speed: 300,
    slidesToShow: 5,
    slidesToScroll: 1,
    centerMode: false,
    variableWidth: true,
    prevArrow:
      '<button type="button" class="slick-prev"><i class="bx bx-arrow-back" ></i></button>',
    nextArrow:
      '<button type="button" class="slick-next"><i class="bx bx-right-arrow-alt"></i></button>',
    responsive: [
      {
        breakpoint: 992,
        settings: {
          slidesToShow: 2,
          slidesToScroll: 1,
          infinite: false,
          dots: false,
          variableWidth: false,
        },
      },
      {
        breakpoint: 768,
        settings: {
          slidesToShow: 1,
          slidesToScroll: 1,
          infinite: false,
          dots: false,
          variableWidth: false,
        },
      },
    ],
  });

  // Function to fetch scores for a specific hole
  function fetchScores(holeNumber) {
    $.ajax({
      url: '/get_scores',
      method: 'GET',
      data: {
        hole_number: holeNumber,
        id: matchId
      },
      success: function(data) {
        // Assuming data is an array of scores
          if (data.length === 0) {
              // If data is empty, set the value of all input fields to 0
              $('[id^="score-"]').val('');
          } else {
            data.forEach(function(score) {
              // Display scores in the input fields, assuming you have inputs with ids like `score-user-id`
              $(`#score-${score.user_id}`).val(score.shots);
            });
          }
      },
      error: function(error) {
        console.error('Error fetching scores:', error);
      }
    });
  }

  // Initial fetch for the first selected hole
  if ($('.holeSlider').length > 0) {
    let initialHoleNumber = $('.holeSlider').slick('slickCurrentSlide') + 1;
    fetchScores(initialHoleNumber);
  };
});
