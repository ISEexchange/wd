name: wd
summary: Watchdog timer for other programs

version: 0.9
release: 3%{?dist}

license: GPLv3
group: Applications/System
url: http://github.com/jumanjiman/wd
buildroot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)
source0: %{name}-%{version}.tar.gz

#BuildRequires: EiffelStudio from https://www2.eiffel.com/download
# see README.md for information on installing EiffelStudio

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
%doc README.md
%doc wd-test.sh

%changelog
* Thu Mar 22 2012 Paul Morgan <jumanjiman@gmail.com> 0.9-3
- bump release
- update spec for new readme filename
- convert readme from asciidoc to markdown
- update email address
- add URL to README for system-wide init script
- add URL for estudio-on-Mac installation
- add comment to spec file WRT installing estudio
- update Mac instructions to reference Makefile
- Update README with info for building on Mac OSX

* Wed Oct 20 2010 Paul Morgan <jumanjiman@gmail.com> 0.9-2
- fix URL in spec file (jumanjiman@gmail.com)

* Wed Oct 20 2010 Paul Morgan <jumanjiman@gmail.com> 0.9-1
- new package built with tito

