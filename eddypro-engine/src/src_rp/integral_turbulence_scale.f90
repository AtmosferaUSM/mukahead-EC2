!***************************************************************************
! integral_turbulence_scale.f90
! -----------------------------
! Copyright (C) 2011-2019, LI-COR Biosciences, Inc.  All Rights Reserved.
! Author: Gerardo Fratini
!
! This file is part of EddyPro®.
!
! NON-COMMERCIAL RESEARCH PURPOSES ONLY - EDDYPRO® is licensed for 
! non-commercial academic and government research purposes only, 
! as provided in the EDDYPRO® End User License Agreement. 
! EDDYPRO® may only be used as provided in the End User License Agreement
! and may not be used or accessed for any commercial purposes.
! You may view a copy of the End User License Agreement in the file
! EULA_NON_COMMERCIAL.rtf.
!
! Commercial companies that are LI-COR flux system customers 
! are encouraged to contact LI-COR directly for our commercial 
! EDDYPRO® End User License Agreement.
!
! EDDYPRO® contains Open Source Components (as defined in the 
! End User License Agreement). The licenses and/or notices for the 
! Open Source Components can be found in the file LIBRARIES-ENGINE.txt.
!
! EddyPro® is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!
!***************************************************************************
!
! \brief       Calculate integral turbulence time scale
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine IntegralTurbulenceScale(Set, nrow, ncol)
    use m_rp_global_var
    implicit none
    !> in/out variables
    integer, intent(in) :: nrow, ncol
    real(kind = dbl), intent(in) :: Set(nrow, ncol)
    !> Local variables
    integer :: lag
    integer :: var
    integer :: LagMax
    real(kind = dbl) :: dt
    real(kind = dbl) :: ITS_bill
    real(kind = dbl), allocatable :: w_cross_corr(:,:)
    logical :: w_cross_corr_failed(ncol)
    real(kind = dbl), external :: LaggedCovarianceNoError

    write(*, '(a)', advance = 'no') '   Estimating integral turbulence scale..'

    !> Initializations
    LagMax = nint(RUsetup%tlag_max * Metadata%ac_freq)
    allocate(w_cross_corr(0:LagMax, ncol))
    dt = 1d0 / Metadata%ac_freq

    !> Cross-correlation (w and all variables) functions
    do var = u, gas4
        if (E2Col(var)%present) then
            do lag = 0, LagMax
                w_cross_corr(lag, var) = LaggedCovarianceNoError(Set(:, w), Set(:, var), size(Set, 1), lag, error)
            end do
        end if
    end do

    !> Normalize cross-correlation function
    w_cross_corr_failed = .false.
    do var = u, gas4
        if (var /= w .and. E2Col(var)%present) then
            if (w_cross_corr(0, var) /= 0d0 .and. w_cross_corr(0, var) /= error) then
                w_cross_corr(0:lagMax, var) = w_cross_corr(0:lagMax, var) / w_cross_corr(0, var)
            else
                w_cross_corr_failed(var) = .true.
            end if
        end if
    end do

    !> Integral turbulence scale function
    ITS = 0d0
    select case(RUsetup%its_meth)
        case('cross_0')
            !> First crossing of y = 0
            do var = u, gas4
                if (var /= w .and. E2Col(var)%present) then
                    if (.not. w_cross_corr_failed(var)) then
                        do lag = 0, LagMax
                            if (w_cross_corr(lag, var) < 0d0) exit
                            ITS(var) = ITS(var) + dt * dabs(w_cross_corr(lag, var))
                        end do
                    else
                        ITS(var) = error
                    end if

                else
                    ITS(var) = error
                end if
            enddo
        case('cross_e')
            !> First crossing of y = 1/e
            do var = u, gas4
                if (var /= w .and. E2Col(var)%present) then
                    if (.not. w_cross_corr_failed(var)) then
                        do lag = 0, LagMax
                            if (w_cross_corr(lag, var) <  1d0/exp(1d0)) exit
                            ITS(var) = ITS(var) + dt * dabs(w_cross_corr(lag, var))
                        end do
                    else
                        ITS(var) = error
                    end if
                else
                    ITS(var) = error
                end if
            end do
        case('full_integral')
            !> Integrate over the full range of variation of time-lag
            do var = u, gas4
                if (var /= w .and. E2Col(var)%present) then
                    if (.not. w_cross_corr_failed(var)) then
                        do lag = 0, LagMax
                            ITS(var) = ITS(var) + dt * dabs(w_cross_corr(lag, var))
                        end do
                    else
                        ITS(var) = error
                    end if
                else
                    ITS(var) = error
                end if
            end do
    end select
    deallocate(w_cross_corr)

    !> Filter reasonable values of ITS, in case anything went wrong.
    !> For badly estimated ITS, uses simple formula from Wyngaard (1973), as cited in Billesbach (2012):
    !> "The integraltimescale can be estimated (under neutral stability) as the
    !> instrument height divided by the mean wind speed".
    if (Stats%Mean(u) /= error) then
        ITS_bill = (E2Col(u)%Instr%height - Metadata%d) / Stats%Mean(u)
    else
        ITS_bill = error
    end if
    !> ITS shouldn't be higher than the integral of "1" over the whole time-lag period.
    !> Use a factor of 2 to account for anomalies.
    where (ITS(u:gas4) > 2. * RUsetup%tlag_max .or. ITS(u:gas4) == error)
       ITS(u:gas4) = ITS_bill
    end where
    write(*, '(a)') ' Done.'
end subroutine IntegralTurbulenceScale
