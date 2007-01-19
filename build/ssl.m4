dnl -------------------------------------------------------- -*- autoconf -*-
dnl Copyright 2006 The Apache Software Foundation or its licensors, as
dnl applicable.
dnl
dnl Licensed under the Apache License, Version 2.0 (the "License");
dnl you may not use this file except in compliance with the License.
dnl You may obtain a copy of the License at
dnl
dnl     http://www.apache.org/licenses/LICENSE-2.0
dnl
dnl Unless required by applicable law or agreed to in writing, software
dnl distributed under the License is distributed on an "AS IS" BASIS,
dnl WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
dnl See the License for the specific language governing permissions and
dnl limitations under the License.

dnl
dnl SSL module
dnl

dnl
dnl APU_FIND_SSL: look for ssl libraries and headers
dnl
AC_DEFUN([APU_FIND_SSL], [
  apu_have_ssl=0

  AC_ARG_WITH([ssl], [APR_HELP_STRING([--with-ssl], [enable SSL support])],
  [
    if test "$withval" = "yes"; then
      APU_CHECK_OPENSSL
      dnl add checks for other varieties of ssl here
    fi
  ], [
      apu_have_ssl=0
  ])

  if test "$apu_have_ssl" = "1"; then
    AC_DEFINE([APU_HAVE_SSL], 1, [Define that we have SSL capability])
  fi

])
dnl

AC_DEFUN([APU_CHECK_OPENSSL], [
  apu_have_openssl=0
  openssl_have_headers=0
  openssl_have_libs=0

  AC_ARG_WITH([openssl], 
  [APR_HELP_STRING([--with-openssl=DIR], [specify location of OpenSSL])],
  [
    if test "$withval" = "yes"; then
      AC_CHECK_HEADERS(openssl/x509.h, [openssl_have_headers=1])
      AC_CHECK_LIB(crypto, BN_init, AC_CHECK_LIB(ssl, SSL_accept, [openssl_have_libs=1]))
      if test "$openssl_have_headers" != "0" && test "$openssl_have_libs" != "0"; then
        apu_have_openssl=1
      fi
    elif test "$withval" = "no"; then
      apu_have_openssl=0
    else
      old_cppflags="$CPPFLAGS"
      old_ldflags="$LDFLAGS"

      openssl_CPPFLAGS="-I$withval/include"
      openssl_LDFLAGS="-L$withval/lib "

      APR_ADDTO(CPPFLAGS, [$openssl_CPPFLAGS])
      APR_ADDTO(LDFLAGS, [$openssl_LDFLAGS])

      AC_MSG_NOTICE(checking for openssl in $withval)
      AC_CHECK_HEADERS(openssl/x509.h, [openssl_have_headers=1])
      AC_CHECK_LIB(crypto, BN_init, AC_CHECK_LIB(ssl, SSL_accept, [openssl_have_libs=1]))
      if test "$openssl_have_headers" != "0" && test "$openssl_have_libs" != "0"; then
        apu_have_openssl=1
        APR_ADDTO(APRUTIL_LDFLAGS, [-L$withval/lib])
        APR_ADDTO(APRUTIL_INCLUDES, [-I$withval/include])
      fi

      if test "$apu_have_openssl" != "1"; then
        AC_CHECK_HEADERS(openssl/x509.h, [openssl_have_headers=1])
        AC_CHECK_LIB(crypto, BN_init, AC_CHECK_LIB(ssl, SSL_accept, [openssl_have_libs=1]))
        if test "$openssl_have_headers" != "0" && test "$openssl_have_libs" != "0"; then
          apu_have_openssl=1
          APR_ADDTO(APRUTIL_LDFLAGS, [-L$withval/lib])
          APR_ADDTO(APRUTIL_INCLUDES, [-I$withval/include])
        fi
      fi

      CPPFLAGS="$old_cppflags"
      LDFLAGS="$old_ldflags"
    fi
  ], [
    AC_CHECK_HEADERS(openssl/x509.h, [openssl_have_headers=1])
    AC_CHECK_LIB(crypto, BN_init, AC_CHECK_LIB(ssl, SSL_accept, [openssl_have_libs=1]))
    if test "$openssl_have_headers" != "0" && test "$openssl_have_libs" != "0"; then
      apu_have_openssl=1
    fi
  ])


  AC_SUBST(apu_have_openssl)

  dnl Add the libraries we will need now that we have set apu_have_openssl correctly
  if test "$apu_have_openssl" = "1"; then
    AC_DEFINE([APU_HAVE_OPENSSL], 1, [Define that we have OpenSSL available])
    APR_ADDTO(APRUTIL_EXPORT_LIBS,[-lssl -lcrypto])
    APR_ADDTO(APRUTIL_LIBS,[-lssl -lcrypto])
    apu_have_ssl=1
  fi
])
dnl
