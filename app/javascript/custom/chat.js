import autoScroll from "./autoScroll.js";

document.addEventListener('turbo:load', function() {
  console.log("turbo:load event triggered");

  function adjustConvoHeight() {
    const windowHeight = window.innerHeight;
    const headerHeight = document.querySelector('section:nth-of-type(1)').offsetHeight;
    const formHeight = document.getElementById('formSection').offsetHeight;
    const convoHeight = windowHeight - headerHeight - formHeight;

    console.log(`windowHeight: ${windowHeight}`);
    console.log(`headerHeight: ${headerHeight}`);
    console.log(`formHeight: ${formHeight}`);
    console.log(`convoHeight: ${convoHeight}`);

    document.getElementById('convoSection').style.height = convoHeight + 'px';
  }

  adjustConvoHeight();

  window.addEventListener('resize', function() {
    adjustConvoHeight();
  });

  document.getElementById('expandableTextarea').addEventListener('input', function() {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight > 120 ? 120 : this.scrollHeight) + 'px';
    adjustConvoHeight();
  });

  // Clear the form input after a successful Turbo Stream response
  document.addEventListener('turbo:submit-end', function(event) {
    if (event.detail.success) {
      const form = document.getElementById('chatForm');
      form.reset();
      // Reset the textarea height
      const textarea = document.getElementById('expandableTextarea');
      textarea.style.height = 'auto';
      adjustConvoHeight();
    }
  });

  // Scroll to bottom after Turbo Frame renders new content
  document.addEventListener('turbo:frame-render', function(event) {
    if (event.target.id === 'messages') {
      console.log("Turbo Frame 'messages' rendered");
      autoScroll();
    }
  });

  // Scroll to bottom after Turbo Stream append
  document.addEventListener('turbo:before-stream-render', function(event) {
    if (event.target.action === 'append' && event.target.target === 'messages') {
      autoScroll();
    }
  });
});
