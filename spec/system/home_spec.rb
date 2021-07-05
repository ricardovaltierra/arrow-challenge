require 'system_helper'

RSpec.describe 'Home', type: :system do
  it 'is under construction' do
    visit root_path

    # ICALIA TIP: Use `debug` or `debug binding` instead of `debugger` in system
    # specs to pause the spec. Open 'localhost:3333' in Chrome to open the
    # project's browserless app, which should list an option to inspect the
    # spec's capybara browser session:
    #
    # debug binding

    expect(page).to have_content 'Find me in app/views/home/show.html.erb'
  end
end
