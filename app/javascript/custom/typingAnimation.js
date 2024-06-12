document.addEventListener("turbo:load", function() {
    const chatForm = document.getElementById("chatForm");
    const typingIndicator = document.getElementById("typingIndicator");
    const messagesContainer = document.getElementById("messages");
    let typingIndicatorTimeout = null;
    const typingIndicatorMinDuration = 100;

    // Show typing indicator on form submit
    chatForm.addEventListener("submit", function(event) {
        typingIndicator.classList.remove("hidden-animation");
        autoScroll(); // Auto-scroll immediately when typing starts
        if (typingIndicatorTimeout) {
            clearTimeout(typingIndicatorTimeout);
        }
    });

    // Observe changes in the messages container to hide typing indicator
    const observer = new MutationObserver(function(mutationsList, observer) {
        for (let mutation of mutationsList) {
            if (mutation.type === 'childList' && mutation.addedNodes.length > 0) {
                autoScroll(); // Auto-scroll when new messages are added
                
                // Ensure the typing indicator lasts at least 3 seconds
                if (!typingIndicatorTimeout) {
                    typingIndicatorTimeout = setTimeout(() => {
                        typingIndicator.classList.add("hidden-animation");
                        typingIndicatorTimeout = null;
                        autoScroll(); // Auto-scroll again after hiding the indicator
                    }, typingIndicatorMinDuration);
                } else {
                    typingIndicator.classList.add("hidden-animation");
                    autoScroll(); // Auto-scroll again if the indicator is hidden immediately
                }
            }
        }
    });

    // Configure the observer
    const config = { childList: true };

    // Start observing the messages container
    observer.observe(messagesContainer, config);

    // Auto-scroll function
    function autoScroll() {
        document.getElementById('auto-scroll-anchor').scrollIntoView({ behavior: "smooth" });
    }
});