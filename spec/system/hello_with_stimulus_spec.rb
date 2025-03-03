require 'rails_helper'

describe "User can see hello world from stimulus", type: :system, js: true do
  it 'with success' do
    visit root_path

    expect(page).to have_content 'Hello World from Stimulus!'
  end
end
