Flipflop.configure do
  # Strategies will be used in the order listed here.
  strategy :cookie
  strategy :default

  feature :design_system, description: "Use the design system layout and components instead of `gov_admin_template`", default: false
end
