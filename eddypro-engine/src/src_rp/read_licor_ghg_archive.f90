!***************************************************************************
! read_licor_ghg_archive.f90
! --------------------------
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
! \brief       Read one LI-COR GHG raw file and store all data and metadata
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine ReadLicorGhgArchive(ZipFile, FirstRecord, LastRecord, LocCol, &
    LocBypassCol, MetaIsNeeded, BiometIsNeeded, DataIsNeeded, ValidateMetadata, &
    fRaw, nrow, ncol, skip_file, passed, faulty_col, N, FileEndReached, printout)

    use m_rp_global_var
    implicit none
    !> in/out variables
    integer, intent(in) :: FirstRecord
    integer, intent(in) :: LastRecord
    integer, intent(in) :: nrow, ncol
    character(*), intent(in) :: ZipFile
    logical, intent(in) :: MetaIsNeeded
    logical, intent(in) :: BiometIsNeeded
    logical, intent(in) :: DataIsNeeded
    logical, intent(in) :: ValidateMetadata
    logical, intent(in) :: printout
    integer, intent(out) :: N
    integer, intent(out) :: faulty_col
    real(kind = sgl), intent(out) :: fRaw(nrow, ncol)
    logical, intent(out) :: skip_file
    logical, intent(out) :: passed(32)
    type(ColType), intent(inout) :: LocCol(MaxNumCol)
    type(ColType), intent(inout) :: LocBypassCol(MaxNumCol)
    logical, intent(out) :: FileEndReached
    !> local variables
    integer :: del_status
    character(PathLen) :: MetaFile
    character(PathLen) :: DataFile
    character(PathLen) :: BiometFile
    character(PathLen) :: BiometMetaFile
    character(CommLen) :: comm
    logical :: skip_biomet_file


    skip_file = .false.
    passed = .true.

    !> Unzip archive
    call UnZipArchive(ZipFile, 'metadata','data', MetaFile, DataFile, &
        BiometFile, BiometMetaFile, skip_file)
    if (skip_file) return

    if (MetaFile /= 'none') &
        MetaFile = trim(adjustl(TmpDir)) // trim(Metafile)
    if (DataFile /= 'none') &
        DataFile = trim(adjustl(TmpDir)) // trim(DataFile)
    if (BiometMetaFile /= 'none') &
        BiometMetaFile = trim(adjustl(TmpDir)) // trim(BiometMetaFile)
    if (BiometFile /= 'none') &
        BiometFile = trim(adjustl(TmpDir)) // trim(BiometFile)

    !> First, handle biomet data and metadata files
    if (BiometIsNeeded) then
        if (BiometFile == 'none' .or. BiometMetaFile == 'none') then
            fnbRecs = 0
            call ExceptionHandler(5)
        else
            call ReadBiometMetaFile(BiometMetaFile, skip_biomet_file)
            if (.not. skip_biomet_file) &
                call ReadBiometFile(BiometFile, skip_biomet_file)
            if (skip_biomet_file) then
                fnbRecs = 0
                call ExceptionHandler(44)
            end if
        end if
    end if

    !> Handle metadata file
    if (MetaIsNeeded) then
        if (MetaFile == 'none') then
            call ExceptionHandler(3)
            skip_file = .true.
            return
        end if
        call ReadMetadataFile(LocCol, MetaFile, skip_file, printout)
        if (skip_file) return
        if (DataIsNeeded) then

            !> If it's in the raw file processing loop, define used variables
            !> based on variables already identified (LocBypassCol)
            call RetrieveVarsSelection(LocBypassCol, LocCol)
        else
            !> In the preamble phase
            !> Embedded mode: define variables to be used,
            !> based on availability in the metadata file
            if (EddyProProj%run_env == 'embedded' &
                .and. EddyProProj%run_mode == 'express') &
                call DefaultVarsSelection(LocCol)
            !> Desktop mode: define used variables based on user selection
            !> at processing-time from GUI
            call DefineUsedVariables(LocCol)
        end if
        if (ValidateMetadata) then
            call MetadataFileValidation(Col, passed, faulty_col)
            if (.not. passed(1)) return
        else
            passed(1) = .true.
        end if
    end if

    !> Handle raw data file
    if (DataIsNeeded) then
        if (DataFile == 'none') then
            call ExceptionHandler(4)
            skip_file = .true.
            return
        end if
        call ImportNativeData(DataFile, FirstRecord, LastRecord, &
            LocCol, fRaw, size(fRaw, 1), size(fRaw, 2), &
            skip_file, N, FileEndReached)
        if (skip_file) return
    end if

    !> Delete data and metadata files
    comm = (trim(comm_del) // ' ' // DataFile(1:len_trim(DataFile)) // ' ' &
        // trim(adjustl(MetaFile)) // ' ' &
        // trim(adjustl(BiometFile)) // ' ' &
        // trim(adjustl(BiometMetaFile)) &
        // ' *.status ' // comm_err_redirect)

    del_status = system(trim(comm))
end subroutine ReadLicorGhgArchive
