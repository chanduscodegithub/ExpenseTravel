// const defaults = {
//   disableForReducedMotion: true
// };
function fire(particleRatio, opts) {
  /*window.confetti(
    Object.assign({}, defaults, opts, {
      particleCount: Math.floor(200 * particleRatio)
    })
  );*/


  window.confetti({
    origin: opts.origin,
    spread: opts.spread,
    startVelocity: opts.startVelocity,
    decay: opts.decay,
    scalar: opts.scalar
  });

}
const buildConfetti = e => {
  let rectBound = e.target.getBoundingClientRect();
  const center = {
    x: rectBound.left + rectBound.width / 2,
    y: rectBound.top + rectBound.height / 2
  };
  const origin = {
    x: center.x / window.innerWidth,
    y: (center.y + 50) / window.innerHeight
  };

  fire(0.25, {
    spread: 26,
    startVelocity: 55,
    origin
  });

  fire(0.2, {
    spread: 60,
    origin
  });

  fire(0.35, {
    spread: 10,
    decay: 0.91,
    scalar: 0.8,
    origin
  });

  fire(0.1, {
    spread: 60,
    startVelocity: 25,
    decay: 0.92,
    scalar: 1.2,
    origin
  });

  fire(0.1, {
    spread: 26,
    startVelocity: 45,
    origin
  });
}
export default buildConfetti;