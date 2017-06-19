#
# Copyright 2017, Audian, Inc. All Rights Reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

defmodule Eftp.Client do
  @moduledoc """
  FTP Client functions
  """

  @doc ~S"""
  Connects to an FTP server
  """
  def connect(host, port \\ 21) do
    :inets.start
    case :inets.start(:ftpc, host: '#{host}', port: '#{port}', progress: true) do
      {:ok, pid} ->
        pid
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Authenticate against an ftp server
  """
  def authenticate(pid, username, password) do
    case :ftp.user(pid, '#{username}', '#{password}') do
      :ok -> pid
      {:error, :euser} ->
        {:error, :invalid_auth}
      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Fetch a specific file from the server
  """
  def fetch(pid, remote_filename) when is_binary(remote_filename) do
    local_filename = "priv/fetched/#{remote_filename}"

    case pid do
      {:error, reason} ->
        {:error, reason}
      _ ->
        :ftp.type(pid, :binary)
        case File.exists?("#{local_filename}") do
          false ->
            case :ftp.recv(pid, '#{remote_filename}', '#{local_filename}') do
              :ok -> :ok
              {:error, reason} ->
                File.rm("#{local_filename}")
                {:error, reason}
            end
          true ->
            File.rename("#{local_filename}", "#{local_filename}-#{unixtime()}.backup")
            fetch(pid, remote_filename)
        end
    end
  end

  @doc """
  Fetches a list of files from the server
  """
  def fetch(pid, files) when is_list(files) do
    case pid do
      {:error, reason} ->
        {:error, reason}
      _ ->
        for file <- files do
          case fetch(pid, "#{file}") do
            :ok -> :ok
            {:error, reason} ->
              {:error, reason}
          end
        end
    end
  end

  #-- private --#
  # generate a unix timestamp in case we need to rename files
  defp unixtime() do
    :os.system_time(:seconds)
  end
end
