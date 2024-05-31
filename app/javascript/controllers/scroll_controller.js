import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observer = new MutationObserver(() => this.resetScroll());
    this.observer.observe(this.element, { childList: true, subtree: true });
    this.resetScroll();
  }
  
  disconnect() {
    this.observer.disconnect();
  }

  resetScroll() {
    this.element.scrollTop = this.element.scrollHeight;
  }
}