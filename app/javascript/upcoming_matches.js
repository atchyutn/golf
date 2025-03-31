
document.addEventListener('DOMContentLoaded', function() {
    // Handle round button clicks for both winner and loser brackets
    document.querySelectorAll('.blockBtn').forEach(button => {
        button.addEventListener('click', function() {
            const roundId = this.getAttribute('data-round');

            // Remove active class from all buttons in this button's container
            this.parentNode.querySelectorAll('.blockBtn').forEach(btn => {
                btn.classList.remove('active');
            });

            // Add active class to clicked button
            this.classList.add('active');

            // Hide all round contents in this bracket
            const bracketType = roundId.split('-')[0];
            document.querySelectorAll(`.round-content[id^="${bracketType}-"]`).forEach(content => {
                content.style.display = 'none';
            });

            // Show selected round content
            document.getElementById(roundId).style.display = 'block';
        });
    });

    // Show the first active round content by default
    document.querySelectorAll('.blockBtnWrap').forEach(wrapper => {
        const firstActiveButton = wrapper.querySelector('.blockBtn.active');
        if (firstActiveButton) {
            const roundId = firstActiveButton.getAttribute('data-round');
            document.getElementById(roundId).style.display = 'block';
        }
    });
});