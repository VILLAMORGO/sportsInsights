export default function autoScroll() {
    setTimeout(() => {
      document.getElementById('auto-scroll-anchor').scrollIntoView({behavior: "smooth"});
    }, 1000);
    console.log("Auto-scrolling");
}

autoScroll();