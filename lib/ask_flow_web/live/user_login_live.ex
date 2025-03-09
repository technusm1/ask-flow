defmodule AskFlowWeb.UserLoginLive do
  use AskFlowWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-center py-8 px-4 sm:px-6 lg:px-8">
      <div class="bg-white p-8 rounded-lg shadow-md w-full max-w-md space-y-8">
        <div>
          <h2 class="text-center text-3xl font-bold tracking-tight text-gray-900">
            Log in to account
          </h2>
          <p class="mt-2 text-center text-sm text-gray-600">
            Don't have an account?
            <.link navigate={~p"/users/register"} class="font-medium text-orange-600 hover:text-orange-500">
              Sign up
            </.link>
            for an account now.
          </p>
        </div>

        <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore" class="mt-8 space-y-6">
          <div class="space-y-4">
            <div>
              <.input field={@form[:email]} type="email" label="Email" required class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-orange-500 focus:border-orange-500 focus:z-10 sm:text-sm" />
            </div>
            <div>
              <.input field={@form[:password]} type="password" label="Password" required class="appearance-none rounded-md relative block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-orange-500 focus:border-orange-500 focus:z-10 sm:text-sm" />
            </div>
          </div>

          <div class="flex items-center justify-between">
            <div class="flex items-center">
              <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" class="h-4 w-4 text-orange-600 focus:ring-orange-500 border-gray-300 rounded" />
            </div>
            <div class="text-sm">
              <.link href={~p"/users/reset_password"} class="font-medium text-orange-600 hover:text-orange-500">
                Forgot your password?
              </.link>
            </div>
          </div>

          <div>
            <.button phx-disable-with="Logging in..." class="group relative w-full flex justify-center py-2 px-4 border border-transparent text-sm font-medium rounded-md text-white bg-orange-600 hover:bg-orange-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-orange-500">
              <span class="absolute left-0 inset-y-0 flex items-center pl-3">
                <svg class="h-5 w-5 text-orange-500 group-hover:text-orange-400" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                  <path fill-rule="evenodd" d="M10 1a4.5 4.5 0 00-4.5 4.5V9H5a2 2 0 00-2 2v6a2 2 0 002 2h10a2 2 0 002-2v-6a2 2 0 00-2-2h-.5V5.5A4.5 4.5 0 0010 1zm3 8V5.5a3 3 0 10-6 0V9h6z" clip-rule="evenodd" />
                </svg>
              </span>
              Log in
            </.button>
          </div>
        </.simple_form>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
