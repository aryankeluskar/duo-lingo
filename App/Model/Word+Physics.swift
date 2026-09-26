import Foundation

extension Word {
  static let physics: [Word] = [
    Word(
      deck: .physics,
      term: "Newton's second law",
      note: "mechanics",
      meaning: "Net force equals the rate of change of momentum",
      example: "F = dp/dt = ma   (constant mass)",
      exampleTranslation: "Force doesn't cause motion; it causes changes in motion."
    ),
    Word(
      deck: .physics,
      term: "work–energy theorem",
      note: "mechanics",
      meaning: "Net work done on a body equals its change in kinetic energy",
      example: "W = ΔK = ½mv² − ½mv₀²",
      exampleTranslation: "Skip the forces' history and follow the energy instead."
    ),
    Word(
      deck: .physics,
      term: "angular momentum",
      note: "rotation",
      meaning: "Conserved whenever no net external torque acts",
      example: "L = Iω:  a skater pulls in, I falls, so ω rises.",
      exampleTranslation: "The same law makes planets sweep equal areas in equal times."
    ),
    Word(
      deck: .physics,
      term: "simple harmonic motion",
      note: "oscillations",
      meaning: "Motion under a restoring force proportional to displacement",
      example: "x(t) = A cos(ωt + φ),    ω = √(k/m)",
      exampleTranslation: "The period doesn't depend on amplitude, which is why clocks can keep time."
    ),
    Word(
      deck: .physics,
      term: "Gauss's law",
      note: "electromagnetism",
      meaning: "Flux out of a closed surface is proportional to the charge enclosed",
      example: "∮ E · dA = Q / ε₀",
      exampleTranslation: "With symmetry, a point charge's field falls out in one line: E = q / 4πε₀r²."
    ),
    Word(
      deck: .physics,
      term: "Faraday's law",
      note: "electromagnetism",
      meaning: "A changing magnetic flux induces an EMF",
      example: "ℰ = −dΦ/dt",
      exampleTranslation: "The minus sign is Lenz's law: the induced current opposes the change."
    ),
    Word(
      deck: .physics,
      term: "Ampère–Maxwell law",
      note: "electromagnetism",
      meaning: "Currents and changing electric fields make magnetic fields",
      example: "∮ B · dl = μ₀(I + ε₀ dΦₑ/dt)",
      exampleTranslation: "Maxwell's added term is what lets light travel as an electromagnetic wave."
    ),
    Word(
      deck: .physics,
      term: "first law of thermodynamics",
      note: "thermodynamics",
      meaning: "Energy is conserved: heat in, minus work done by the system",
      example: "ΔU = Q − W",
      exampleTranslation: "Chemists count work done on the system instead and write ΔU = q + w."
    ),
    Word(
      deck: .physics,
      term: "second law of thermodynamics",
      note: "thermodynamics",
      meaning: "The entropy of an isolated system never decreases",
      example: "ΔS ≥ 0.   Carnot limit:  η ≤ 1 − T cold / T hot",
      exampleTranslation: "No engine turns heat entirely into work."
    ),
    Word(
      deck: .physics,
      term: "Schrödinger equation",
      note: "quantum mechanics",
      meaning: "Governs how a quantum state evolves in time",
      example: "iħ ∂ψ/∂t = Ĥψ",
      exampleTranslation: "|ψ|² is the probability density of finding the particle."
    ),
    Word(
      deck: .physics,
      term: "uncertainty principle",
      note: "quantum mechanics",
      meaning: "Position and momentum can't both be sharply defined",
      example: "Δx · Δp ≥ ħ/2",
      exampleTranslation: "It's a property of waves, not a flaw in our instruments."
    ),
    Word(
      deck: .physics,
      term: "de Broglie wavelength",
      note: "quantum mechanics",
      meaning: "Every particle with momentum has a wavelength",
      example: "λ = h / p",
      exampleTranslation: "Electrons diffract like light, which is why electron microscopes work."
    ),
    Word(
      deck: .physics,
      term: "Lorentz factor",
      note: "special relativity",
      meaning: "How much time dilates and length contracts at speed v",
      example: "γ = 1 / √(1 − v²/c²)",
      exampleTranslation: "Moving clocks run slow:  Δt = γ Δt₀."
    ),
  ]
}
