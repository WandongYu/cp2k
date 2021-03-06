!--------------------------------------------------------------------------------------------------!
!   CP2K: A general program to perform molecular dynamics simulations                              !
!   Copyright (C) 2000 - 2020  CP2K developers group                                               !
!--------------------------------------------------------------------------------------------------!

! **************************************************************************************************
!> \brief Includes all necessary routines, functions and parameters from
!>        libxc. Provides CP2K routines/functions where the LibXC calling list
!>        is version dependent (>=4.0.3). The naming convention for such
!>        routines/functions is xc_f03_XXX --> 'xc_libxc_wrap_XXX'. All version
!>        independent routines/functions are just bypassed to higher level
!>        module file 'xc_libxc'.
!>
!> \par History
!>      08.2015 created [A. Gloess (agloess)]
!>      01.2018 refactoring [A. Gloess (agloess)]
!>      10.2018/04.2019 added hyb_mgga [S. Simko, included by F. Stein]
!> \author A. Gloess (agloess)
! **************************************************************************************************
MODULE xc_libxc_wrap
#if defined (__LIBXC)
#include <xc_version.h>
! check for LibXC version
#if (XC_MAJOR_VERSION < 4)
   This version of CP2K ONLY works with libxc versions 4.0.3 and above.
   Furthermore, -I${LIBXC_DIR}/include needs to be added to FCFLAGS.
#else

   ! Functionals which require parameters
   USE cp_log_handling, ONLY: cp_to_string
   USE kinds, ONLY: dp
   USE xc_f03_lib_m, ONLY: xc_f03_func_end, &
                           xc_f03_func_init, &
                           xc_f03_func_set_ext_params, &
                           xc_f03_functional_get_number, &
                           !
                           xc_f03_gga_exc, &
                           xc_f03_gga_exc_vxc, &
                           xc_f03_gga_fxc, &
                           xc_f03_gga_vxc, &
                           !
                           xc_f03_func_get_info, &
                           xc_f03_func_info_get_family, &
                           xc_f03_func_info_get_kind, &
                           xc_f03_func_info_get_name, &
                           xc_f03_func_info_get_references, &
                           xc_f03_func_info_get_flags, &
                           xc_f03_func_info_get_n_ext_params, &
                           xc_f03_func_info_get_ext_params_description, &
                           !
                           xc_f03_func_reference_get_ref, &
                           xc_f03_func_reference_get_doi, &
                           !
                           xc_f03_lda, &
                           xc_f03_lda_exc, &
                           xc_f03_lda_exc_vxc, &
                           xc_f03_lda_fxc, &
                           xc_f03_lda_kxc, &
                           xc_f03_lda_vxc, &
                           !
                           xc_f03_mgga, &
                           xc_f03_mgga_exc, &
                           xc_f03_mgga_exc_vxc, &
                           xc_f03_mgga_fxc, &
                           xc_f03_mgga_vxc, &
                           !
                           xc_f03_func_t, &
                           xc_f03_func_info_t, &
                           xc_f03_func_reference_t, &
                           !
                           XC_FAMILY_LDA, &
                           XC_FAMILY_GGA, &
                           XC_FAMILY_MGGA, &
                           XC_FAMILY_HYB_GGA, &
                           XC_FAMILY_HYB_MGGA, &
                           !
                           XC_UNPOLARIZED, &
                           XC_POLARIZED, &
                           !
                           XC_EXCHANGE, &
                           XC_CORRELATION, &
                           XC_EXCHANGE_CORRELATION, &
                           XC_KINETIC, &
                           !
                           XC_FLAGS_NEEDS_LAPLACIAN, &
                           XC_FLAGS_HAVE_EXC, &
                           XC_FLAGS_DEVELOPMENT

#include "../base/base_uses.f90"

   IMPLICIT NONE
   PRIVATE

   CHARACTER(len=*), PARAMETER, PRIVATE :: moduleN = 'xc_libxc_wrap'

   CHARACTER(LEN=*), PARAMETER, PUBLIC :: libxc_version = XC_VERSION

   PUBLIC :: xc_f03_func_t, xc_f03_func_info_t
   PUBLIC :: xc_f03_func_init, xc_f03_func_end
   PUBLIC :: xc_f03_func_get_info, xc_f03_func_info_get_family, xc_f03_func_info_get_kind, &
             xc_f03_func_info_get_name
   PUBLIC :: xc_f03_gga_exc, xc_f03_gga_exc_vxc, xc_f03_gga_fxc, &
             xc_f03_gga_vxc
   PUBLIC :: xc_f03_lda, &
             xc_f03_lda_exc, xc_f03_lda_exc_vxc, &
             xc_f03_lda_fxc, xc_f03_lda_kxc, xc_f03_lda_vxc
   PUBLIC :: xc_f03_mgga, xc_f03_mgga_exc, xc_f03_mgga_exc_vxc, xc_f03_mgga_fxc, &
             xc_f03_mgga_vxc

   PUBLIC :: XC_FAMILY_LDA, XC_FAMILY_GGA, XC_FAMILY_MGGA, &
             XC_FAMILY_HYB_GGA, XC_FAMILY_HYB_MGGA

   PUBLIC :: XC_UNPOLARIZED, XC_POLARIZED

   PUBLIC :: XC_EXCHANGE, XC_CORRELATION, XC_EXCHANGE_CORRELATION, XC_KINETIC

! wrappers for routines
   PUBLIC :: xc_libxc_wrap_info_refs, &
             xc_libxc_wrap_version, &
             xc_libxc_wrap_functional_get_number, &
             xc_libxc_wrap_needs_laplace, &
             xc_libxc_wrap_functional_set_params, &
             xc_libxc_wrap_is_under_development

CONTAINS

! **************************************************************************************************
!> \brief Provides the reference(s) for this functional.
!> \param xc_info ...
!> \param polarized ...
!> \param sc ...
!> \param reference ...
!>
!> \author A. Gloess (agloess)
! **************************************************************************************************
   SUBROUTINE xc_libxc_wrap_info_refs(xc_info, polarized, sc, reference)
      TYPE(xc_f03_func_info_t), INTENT(IN)               :: xc_info
      INTEGER, INTENT(IN)                                :: polarized
      REAL(KIND=dp), INTENT(IN)                          :: sc
      CHARACTER(LEN=*), INTENT(OUT)                      :: reference

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_info_refs', &
                                     routineP = moduleN//':'//routineN
      INTEGER, PARAMETER                                 :: maxlen = 67

      CHARACTER(LEN=128)                                 :: descr_string
      CHARACTER(LEN=400)                                 :: doi_string, ref_string, tmp_string
      INTEGER                                            :: empty, first, handle, i, i_ref, idx, &
                                                            last, n_params
      TYPE(xc_f03_func_reference_t)                      :: xc_ref

      CALL timeset(routineN, handle)

      i_ref = 0
      idx = 1
      first = 1
      DO WHILE (i_ref >= 0)
         ! information about functional references
         xc_ref = xc_f03_func_info_get_references(xc_info, i_ref)
         ref_string = xc_f03_func_reference_get_ref(xc_ref)
         doi_string = xc_f03_func_reference_get_doi(xc_ref)
         WRITE (tmp_string, '(a1,i1,a2,a,a7,a)') '[', idx, '] ', &
            TRIM(ref_string), ', doi: ', TRIM(doi_string)
         last = first + LEN_TRIM(tmp_string) - 1
         reference(first:last) = TRIM(tmp_string)
         first = last + 1
         empty = last + (maxlen - 1) - MOD(last - 1, maxlen)
         ! fill up line with 'spaces'
         IF (empty /= last) THEN
            reference(first:empty) = ' '
            first = empty + 1
         END IF
         ! information about (optional) external parameters
         n_params = xc_f03_func_info_get_n_ext_params(xc_info)
         IF (n_params > 0) THEN
            reference(first:first + maxlen - 1) = 'Optional external parameters:'//REPEAT(' ', maxlen - 28)
            first = first + maxlen
         END IF
         DO i = 1, n_params
            descr_string = xc_f03_func_info_get_ext_params_description(xc_info, i - 1)
            last = first + LEN_TRIM(descr_string) - 1 + 3
            reference(first:last) = ' * '//TRIM(descr_string)
            first = last + 1
            empty = last + (maxlen - 1) - MOD(last - 1, maxlen)
            ! fill up line with 'spaces'
            IF (empty /= last) THEN
               reference(first:empty) = ' '
               first = empty + 1
            END IF
         END DO
         idx = idx + 1
      END DO
      SELECT CASE (polarized)
      CASE (XC_UNPOLARIZED)
         WRITE (tmp_string, "('{scale=',f5.3,', spin-unpolarized}')") sc
      CASE (XC_POLARIZED)
         WRITE (tmp_string, "('{scale=',f5.3,', spin-polarized}')") sc
      CASE default
         CPABORT("Unsupported value for variable 'polarized'.")
      END SELECT
      last = first + LEN_TRIM(tmp_string) - 1
      reference(first:last) = TRIM(tmp_string)
      first = last + 1
      ! fill with 'spaces'
      reference(first:LEN(reference)) = ' '

      CALL timestop(handle)

   END SUBROUTINE xc_libxc_wrap_info_refs

! **************************************************************************************************
!> \brief Provides a version string.
!> \param version ...
!> \author A. Gloess (agloess)
!>
! **************************************************************************************************
   SUBROUTINE xc_libxc_wrap_version(version)
      CHARACTER(LEN=*), INTENT(OUT)                      :: version

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_version', &
                                     routineP = moduleN//':'//routineN

      INTEGER                                            :: handle

      CALL timeset(routineN, handle)

      version = TRIM(libxc_version)

      CALL timestop(handle)

   END SUBROUTINE xc_libxc_wrap_version

! **************************************************************************************************
!> \brief Provides the functional ID.
!> \param func_string ...
!> \return ...
!> \author A. Gloess (agloess)
!> \note Remove prefix to keep compatibility, functionals can be specified (in
!>       LIBXC section) as:
!>       GGA_X_...  or  XC_GGA_X_...
!>       Starting from version 2.2.0 both name conventions are allowed, before
!>       the 'XC_' prefix was necessary.
!>
! **************************************************************************************************
   INTEGER FUNCTION xc_libxc_wrap_functional_get_number(func_string) RESULT(func_id)
      CHARACTER(LEN=*), INTENT(IN)                       :: func_string

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_functional_get_number', &
                                     routineP = moduleN//':'//routineN

      INTEGER                                            :: handle

      CALL timeset(routineN, handle)

      IF (func_string(1:3) == "XC_") THEN
         func_id = xc_f03_functional_get_number(func_string(4:LEN_TRIM(func_string)))
      ELSE
         func_id = xc_f03_functional_get_number(func_string(1:LEN_TRIM(func_string)))
      END IF
      IF (func_id == -1) THEN
         CPABORT(TRIM(func_string)//": wrong functional name")
      END IF

      CALL timestop(handle)

   END FUNCTION xc_libxc_wrap_functional_get_number

! **************************************************************************************************
!> \brief Wrapper to test wether functional is considered under development in Libxc
!> \param xc_info ...
!>
!> \return ...
!> \author F. Stein (fstein93)
! **************************************************************************************************
   LOGICAL FUNCTION xc_libxc_wrap_is_under_development(xc_info)
      TYPE(xc_f03_func_info_t)                           :: xc_info

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_is_under_development', &
                                     routineP = moduleN//':'//routineN

      IF (IAND(xc_f03_func_info_get_flags(xc_info), XC_FLAGS_DEVELOPMENT) == XC_FLAGS_DEVELOPMENT) THEN
         xc_libxc_wrap_is_under_development = .TRUE.
      ELSE
         xc_libxc_wrap_is_under_development = .FALSE.
      END IF

   END FUNCTION xc_libxc_wrap_is_under_development

! **************************************************************************************************
!> \brief Wrapper for functionals that need the Laplacian, all others can use
!>        a dummy array.
!> \param func_id ...
!>
!> \return ...
!> \author A. Gloess (agloess)
! **************************************************************************************************
   LOGICAL FUNCTION xc_libxc_wrap_needs_laplace(func_id)
      ! Only some MGGA functionals needs the laplacian
      INTEGER, INTENT(IN)                                :: func_id

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_needs_laplace', &
                                     routineP = moduleN//':'//routineN

      INTEGER                                            :: handle
      TYPE(xc_f03_func_info_t)                           :: xc_info
      TYPE(xc_f03_func_t)                                :: xc_func

      CALL timeset(routineN, handle)

      ! Some MGGa need the laplace explicit and some just need an arbitrary array
      ! of the correct size.
      !
      ! Assumption (.true. in v2.1.0 - v4.0.x):
      !             if
      !                functional is Laplace-dependent for XC_UNPOLARIZED
      !             then
      !                functional will be Laplace-dependent for XC_POLARIZED too.
      !
!$OMP CRITICAL(libxc_init)
      CALL xc_f03_func_init(xc_func, func_id, XC_UNPOLARIZED)
      xc_info = xc_f03_func_get_info(xc_func)
!$OMP END CRITICAL(libxc_init)
!$OMP BARRIER
      IF (IAND(xc_f03_func_info_get_flags(xc_info), XC_FLAGS_NEEDS_LAPLACIAN) == XC_FLAGS_NEEDS_LAPLACIAN) THEN
         xc_libxc_wrap_needs_laplace = .TRUE.
      ELSE
         xc_libxc_wrap_needs_laplace = .FALSE.
      END IF

      CALL xc_f03_func_end(xc_func)

      CALL timestop(handle)

   END FUNCTION xc_libxc_wrap_needs_laplace

! **************************************************************************************************
!> \brief Wrapper for functionals that need special parameters.
!> \param xc_func ...
!> \param xc_info ...
!> \param params ...
!> \param no_exc ...
!>
!> \author A. Gloess (agloess)
! **************************************************************************************************
   SUBROUTINE xc_libxc_wrap_functional_set_params(xc_func, xc_info, params, no_exc)
      TYPE(xc_f03_func_t), INTENT(INOUT)                 :: xc_func
      TYPE(xc_f03_func_info_t), INTENT(IN)               :: xc_info
      REAL(KIND=dp), DIMENSION(:), INTENT(IN), POINTER   :: params
      LOGICAL, INTENT(INOUT)                             :: no_exc

      CHARACTER(LEN=*), PARAMETER :: routineN = 'xc_libxc_wrap_functional_set_params', &
                                     routineP = moduleN//':'//routineN

      INTEGER                                            :: handle, i_params, n_params

      CALL timeset(routineN, handle)

      n_params = xc_f03_func_info_get_n_ext_params(xc_info)
      i_params = SIZE(params)

      IF ((n_params > 0) .AND. (i_params > 0) .AND. (params(1) < HUGE(0.0_dp))) THEN
         IF (i_params == n_params) THEN
            CALL xc_f03_func_set_ext_params(xc_func, params)
         ELSE
            CALL cp_abort(__LOCATION__, &
               "LIBXC: Inconsistent number of optional external parameters. (required: "&
               &//cp_to_string(n_params)//", given: "//cp_to_string(i_params)//")")
         END IF
      END IF

      IF (IAND(xc_f03_func_info_get_flags(xc_info), XC_FLAGS_HAVE_EXC) == XC_FLAGS_HAVE_EXC) THEN
         no_exc = .FALSE.
      ELSE
         no_exc = .TRUE.
      END IF

      CALL timestop(handle)

   END SUBROUTINE xc_libxc_wrap_functional_set_params

#endif
#endif
END MODULE xc_libxc_wrap
