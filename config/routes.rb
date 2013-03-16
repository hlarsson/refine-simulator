RefineSimulator::Application.routes.draw do
  get "refine/index"
  post "refine/run"

  root :to => 'refine#index'
end
