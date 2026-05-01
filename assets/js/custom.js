/* custom.js */
const centerBox = document.getElementById("centerBox");
if (centerBox) {
  centerBox.addEventListener("click", () => {
    centerBox.classList.add("revealed");
  });
}

document.querySelectorAll(".bouncy").forEach((el) => {
  const text = el.textContent;
  el.textContent = "";
  [...text].forEach((char, i) => {
    if (char === " ") {
      el.appendChild(document.createTextNode(" "));
      return;
    }
    const span = document.createElement("span");
    span.textContent = char;
    span.style.animationDelay = `${i * 0.1}s`;
    el.appendChild(span);
  });
});
