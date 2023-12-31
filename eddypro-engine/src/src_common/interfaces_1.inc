interface
    subroutine fcn(m, npar, x, fvec, fjac, iflag)
        implicit none
        integer, parameter :: dbl   = kind(0.0d0)
        integer, intent(in)            :: m, npar
        real(kind = dbl), intent(in)    :: x(:)
        real(kind = dbl), intent(inout) :: fvec(:)
        real(kind = dbl), intent(out)   :: fjac(:,:)
        integer, intent(inout)         :: iflag
    end subroutine fcn
end interface

interface
    function SwVerFromString(string)
        use m_common_global_var
        implicit none
        !> in/out variables
        character(*), intent(in) :: string
        type(SwVerType) :: SwVerFromString
        !> Local variables
        character(4) :: chunk
    end function
end interface

interface
    function CompareSwVer(v1, v2)
        use m_common_global_var
        implicit none
        !> In/out variables
        type(SwVerType), intent(in) :: v1
        type(SwVerType), intent(in) :: v2
        logical :: CompareSwVer
    end function
end interface

interface
    function EqualSwVer(v1, v2)
        use m_common_global_var
        implicit none
        !> In/out variables
        type(SwVerType), intent(in) :: v1
        type(SwVerType), intent(in) :: v2
        logical :: EqualSwVer
    end function
end interface

interface
    function DefaultSonicOutputRate(model)
        use m_common_global_var
        implicit none
        !> In/out variables
        character(*), intent(in) :: model
        integer :: DefaultSonicOutputRate
    end function
end interface

interface
    function sinc(x, N)
        use m_numeric_kinds
        implicit none
        !> In/out variables
        integer, intent(in) :: N
        real(kind = dbl) , intent(in) :: x(N)
        real(kind = dbl)  :: sinc(N)
    end function
end interface

interface
    function asymmetric_linear_transformation(x, N, pgain, poffset, ngain, noffset)
        use m_numeric_kinds
        implicit none
        !> In/out variables
        integer, intent(in) :: N
        real(kind = dbl) , intent(inout) :: x(N)
        real(kind = dbl) , intent(in) :: pgain
        real(kind = dbl) , intent(in) :: poffset
        real(kind = dbl) , intent(in) :: ngain
        real(kind = dbl) , intent(in) :: noffset
        real(kind = dbl)  :: asymmetric_linear_transformation(N)
    end function
end interface

interface
    function CountRecordsAndValues(Set, nrow, ncol, var1, var2)
        use m_common_global_var
        implicit none
        !> In/out variables
        integer, intent(in) :: nrow, ncol
        real(kind = dbl), intent(in) :: Set(nrow, ncol)
        integer, optional, intent(in) :: var1, var2
        integer :: CountRecordsAndValues
    end function
end interface

interface
    function PotentialRadiation(latit) result(RP)
        use m_common_global_var
        implicit none
        !> in/out variables
        real(kind = dbl), intent(in) :: latit
        real(kind = dbl) :: RP(17568)
    end function
end interface


interface
    function DateTimeToHalfHourNumber(date, time) result(indx)
        character(*), intent(in) :: date
        character(*), intent(in) :: time
        integer :: indx
    end function
end interface


interface
    function replace(string, what, with, outlen) result(nstring)
        use m_common_global_var
        implicit none
        !> in/out variables
        integer, intent(in) :: outlen
        character(*), intent(in) :: string
        character(*), intent(in) :: what
        character(*), intent(in) :: with
        character(outlen) :: nstring
    end function
end interface

interface
    function replace2(string, what, with) result(nstring)
        use m_common_global_var
        implicit none
        !> in/out variables
        character(*), intent(in) :: string
        character(*), intent(in) :: what
        character(*), intent(in) :: with
        character(:), allocatable :: nstring
    end function
end interface

interface 
    function strCharIndex(s, c, n) result(ix)
        use m_common_global_var
        implicit none
        !> In/out variables
        character(*),intent(in) :: s
        character(*),intent(in) :: c
        integer, intent(in) :: n
        integer :: ix
    end function
end interface

interface
    function strByInt(i) result(res)
        character(:),allocatable :: res
        integer,intent(in) :: i
        character(range(i)+2) :: tmp
    end function
end interface

interface 
    subroutine AddFloatDatumToDataline(float_datum, dataline, err_label, gain, offset)
        use m_common_global_var
        implicit none
        !> in/out variables
        real(kind = dbl), intent(in) :: float_datum
        real(kind = dbl), optional, intent(in) :: gain
        real(kind = dbl), optional, intent(in) :: offset
        character(*), intent(in) :: err_label
        character(*), intent(inout) :: dataline
        character(DatumLen) :: char_datum
    end subroutine
end interface

interface 
    subroutine WriteDatumFloat(float_datum, char_datum, err_label, gain, offset)
        use m_common_global_var
        implicit none
        !> in/out variables
        real(kind = dbl), intent(in) :: float_datum
        real(kind = dbl), optional, intent(in) :: gain
        real(kind = dbl), optional, intent(in) :: offset
        character(*), intent(out) :: char_datum
        character(*), intent(in) :: err_label
        real(kind = dbl) :: val
    end subroutine
end interface
