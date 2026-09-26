import Foundation

extension Word {
  static let calculus: [Word] = [
    Word(
      deck: .calculus,
      term: "chain rule",
      note: "differentiation",
      meaning: "Derivative of the outer at the inner, times the inner's derivative",
      example: "d/dx sin(x²) = 2x cos(x²)",
      exampleTranslation: "Rates multiply through each layer of a composition."
    ),
    Word(
      deck: .calculus,
      term: "fundamental theorem",
      note: "integration",
      meaning: "Differentiation and integration undo each other",
      example: "∫ₐᵇ f(x) dx = F(b) − F(a),   where F′ = f",
      exampleTranslation: "Area under a curve becomes an antiderivative checked at two points."
    ),
    Word(
      deck: .calculus,
      term: "L'Hôpital's rule",
      note: "limits",
      meaning: "For 0/0 or ∞/∞, take the limit of f′/g′ instead",
      example: "lim x→0  sin x / x  =  lim x→0  cos x / 1  =  1",
      exampleTranslation: "It only applies to indeterminate forms, so check the form first."
    ),
    Word(
      deck: .calculus,
      term: "Taylor series",
      note: "series",
      meaning: "A function as a power series built from its derivatives at a point",
      example: "eˣ = 1 + x + x²/2! + x³/3! + ⋯",
      exampleTranslation: "Cut it off early and you get the best polynomial fit near that point."
    ),
    Word(
      deck: .calculus,
      term: "mean value theorem",
      note: "differentiability",
      meaning: "Somewhere the instantaneous slope equals the average slope",
      example: "f′(c) = (f(b) − f(a)) / (b − a)   for some c in (a, b)",
      exampleTranslation: "Drive 120 km in an hour and at some moment you were doing exactly 120 km/h."
    ),
    Word(
      deck: .calculus,
      term: "integration by parts",
      note: "integration",
      meaning: "∫ u dv = uv − ∫ v du",
      example: "∫ x eˣ dx = x eˣ − eˣ + C",
      exampleTranslation: "The product rule, run in reverse."
    ),
    Word(
      deck: .calculus,
      term: "∫ sec²x dx",
      note: "integration",
      meaning: "tan x + C",
      example: "because  d/dx tan x = sec²x",
      exampleTranslation: "Every derivative rule, read backward, is an integration rule."
    ),
    Word(
      deck: .calculus,
      term: "∫ 1/(1 + x²) dx",
      note: "integration",
      meaning: "arctan x + C",
      example: "∫₀¹ dx / (1 + x²) = π/4",
      exampleTranslation: "The substitution x = tan θ turns it into ∫ dθ."
    ),
    Word(
      deck: .calculus,
      term: "d/dx ln x",
      note: "differentiation",
      meaning: "1/x,  for x > 0",
      example: "d/dx ln|x| = 1/x  for every x ≠ 0",
      exampleTranslation: "That's why ∫ dx/x = ln|x| + C."
    ),
    Word(
      deck: .calculus,
      term: "ratio test",
      note: "series",
      meaning: "Σ aₙ converges absolutely if lim |aₙ₊₁ / aₙ| < 1",
      example: "Σ 1/n!:  the ratio is 1/(n + 1) → 0, so it converges.",
      exampleTranslation: "If the limit is exactly 1, the test says nothing; try another."
    ),
    Word(
      deck: .calculus,
      term: "gradient",
      note: "multivariable",
      meaning: "The vector of partial derivatives, pointing uphill fastest",
      example: "f = x²y   →   ∇f = (2xy, x²)",
      exampleTranslation: "Its length is the steepest rate of climb; gradient descent follows −∇f."
    ),
    Word(
      deck: .calculus,
      term: "polar area element",
      note: "multiple integrals",
      meaning: "dA = r dr dθ",
      example: "∬ e^(−x²−y²) dA = π  over the whole plane",
      exampleTranslation: "Going polar is how you prove ∫ e^(−x²) dx = √π over the whole real line."
    ),
  ]
}
