name: wd
summary: Watchdog timer for other programs

version: 0.9
release: 1%{?dist}

license: GPLv3
group: Applications/System
url: http://github.com/jumanjiman/watchdog
buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
source0: %{name}-%{version}.tar.gz

#BuildRequires: EiffelStudio from https://www2.eiffel.com/download

%description
Acts as a watchdog timer to start other programs.
The other program must finish within a configurable timeout or
else the other program is killed. See wd-test.sh (provided)
for example usage.

%prep
%setup -q

%clean
%{__rm} -fr %{buildroot}

%build
make finalize

%install
%{__rm} -fr %{buildroot}
%{__mkdir_p} %{buildroot}%{_bindir}
%{__install} -pm755 bin/wd %{buildroot}%{_bindir}

%files
%defattr(-,root,root,-)
%{_bindir}/wd
%doc COPYING.GPLv3
%doc README.asciidoc
%doc wd-test.sh

%changelog
* Wed Oct 20 2010 Paul Morgan <jumanjiman@gmail.com> 0.9-1
- new package built with tito

