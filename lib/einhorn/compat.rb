module Einhorn
  module Compat
    # In Ruby 2.1.0 (and possibly earlier), IO.pipe sets cloexec on
    # the descriptors.
    def self.pipe
      readable, writeable = IO.pipe
      cloexec!(readable, false)
      cloexec!(writeable, false)
      [readable, writeable]
    end

    def self.cloexec!(fd, enable)
      original = fd.fcntl(Fcntl::F_GETFD)
      if enable
        new = original | Fcntl::FD_CLOEXEC
      else
        new = original & (-Fcntl::FD_CLOEXEC-1)
      end
      fd.fcntl(Fcntl::F_SETFD, new)
    end

    def self.cloexec?(fd)
      fd.fcntl(Fcntl::F_GETFD) & Fcntl::FD_CLOEXEC
    end

    # Opts are ignored in Ruby 1.8
    def self.exec(script, args, opts={})
      cmd = [script, script]
      begin
        Kernel.exec(cmd, *(args + [opts]))
      rescue TypeError
        Kernel.exec(cmd, *args)
      end
    end

    def self.unixserver_new(path)
      server = UNIXServer.new(path)
      cloexec!(server, false)
      server
    end

    def self.accept_nonblock(server)
      sock = server.accept_nonblock
      cloexec!(sock, false)
      sock
    end
  end
end
