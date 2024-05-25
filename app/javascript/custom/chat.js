import jQuery from "jquery";
window.$ = window.jQuery = jQuery;

document.addEventListener('DOMContentLoaded', function() {
  console.log("DOMContentLoaded event triggered");

  function adjustConvoHeight() {
    const windowHeight = $(window).height();
    const headerHeight = $('section:nth-of-type(1)').outerHeight();
    const formHeight = $('#formSection').outerHeight();
    const convoHeight = windowHeight - headerHeight - formHeight;

    console.log(`windowHeight: ${windowHeight}`);
    console.log(`headerHeight: ${headerHeight}`);
    console.log(`formHeight: ${formHeight}`);
    console.log(`convoHeight: ${convoHeight}`);

    $('#convoSection').css('height', convoHeight + 'px');
  }

  function scrollToBottom() {
    const $convoSection = $('#convoSection');
    $convoSection.scrollTop($convoSection.prop("scrollHeight"));
  }

  adjustConvoHeight();
  scrollToBottom();

  $(window).resize(function() {
    adjustConvoHeight();
    scrollToBottom();
  });

  $('#expandableTextarea').on('input', function() {
    this.style.height = 'auto';
    this.style.height = (this.scrollHeight > 120 ? 120 : this.scrollHeight) + 'px';
    adjustConvoHeight();
  });

  // MutationObserver to scroll to bottom when new messages are added
  const observer = new MutationObserver(function(mutationsList) {
    for (const mutation of mutationsList) {
      if (mutation.type === 'childList') {
        console.log("New child added to convoSection");
        scrollToBottom();
      }
    }
  });

  const target = document.querySelector('#convoSection > div');
  if (target) {
    observer.observe(target, { childList: true, subtree: true });
  } else {
    console.error("Target for MutationObserver not found");
  }

  // Ensure the scroll position is set after the entire page is loaded
  $(window).on('load', function() {
    console.log("windows on load")
    scrollToBottom();
  });
});
