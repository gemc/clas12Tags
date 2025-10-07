      program av
c     ==========
c
c     Calculating the mean number of photoelectrons
c     for 1.0 cm for electrons in Cerenkov gas.
c     case CO2
c     Information stored in the file "det_CO2.dat"
c     1 - wavelength in nm
c     2 - mylar reflectivity (old variant)
c     3 - Al + MgF2 (mylar) from ORIEL instruments
c     4 - beral reflectivity
c     5 - bialkali cathod standard quantum efficiency
c         with borosilicate window
c     6 - bialkali cathod  quantum efficiency with UV glass
c     7 - bialkali cathod  quantum efficiency with fused cilica
c         ( kvarts )

c     8 - gas transparency for 1 m
c
      implicit none
      save
c
      integer i,iw
      real an,etol,acon,sin2t,photn,sum_phot,ref_prop
      real r_mylar(47), r_al_mgf2(47), r_beral(47)
      real qe_std(47), qe_UV(47), qe_kvarts(47)
      real alamb(47), phn(47), g_trans(47), s
      real deltlam,e_max,e_min,delt_e,trans,qe,refl,alen,ref_c
c
      real qe_use(47), refl_use(47), gas_length
c     ==========================================> Used values !
c
c      data an / 1.00041 /       ! CO2 refraction index
      data an / 1.00138 /       ! C4F10 refraction index
c      data an / 1.03 /           ! aerogel refraction index
c
      data etol/ 1239.84244 /    ! The 1.0 nm photon energy (eV)
      data acon /370.0/          ! Constant (alpha/hc) eV-1, cm-1 
c
      common /pawc/ iw(100000)
  900 format(i5,4f10.3/)
  901 format(2f12.4) 
c
      call hlimit(99000)
c
      call hbook1(1,'mylar reflectiviti',50,185.,685.,0.)
      call hbook1(2,'Al + MgF2 reflectiviti',50,185.,685.,0.)
      call hbook1(3,'beral reflectiviti',50,185.,685.,0.)
      call hbook1(4,'quantum efficiency std',50,185.,685.,0.)
      call hbook1(5,'quantum efficiency UV glass',50,185.,685.,0.)
      call hbook1(6,'quantum efficiency kvartz',50,185.,685.,0.)
      call hbook1(7,'CO2 transparency',50,185.,685.,0.)
      call hbook1(8,'Cerenkov spectr',50,185.,685.,0.)
c
      open(unit=10,file='det_CO2.dat',status='OLD')
c
      do i = 1,47
        read(10,*) alamb(i),r_mylar(i),r_al_mgf2(i), r_beral(i),
     &  qe_std(i), qe_UV(i), qe_kvarts(i), g_trans(i)
      end do
c
      do i = 1,47
        call hf1(1,alamb(i),r_mylar(i))
        call hf1(2,alamb(i),r_al_mgf2(i))
        call hf1(3,alamb(i),r_beral(i))
        call hf1(4,alamb(i), qe_std(i))
        call hf1(5,alamb(i), qe_UV(i))
        call hf1(6,alamb(i), qe_kvarts(i))
        call hf1(7,alamb(i),g_trans(i))
        s = 28.3*etol/alamb(i)/alamb(i)
        call hf1(8,alamb(i),s)
      end do
      call hrput(0,'refl_n.rz',' ')
c
c     Parameter choise
c     ================================
      call ucopy(qe_kvarts, qe_use, 47)
c      call ucopy(qe_UV, qe_use, 47)
c      call ucopy(r_beral, refl_use, 47)
c      call ucopy(r_mylar, refl_use, 47)
      call ucopy(r_al_mgf2, refl_use, 47)
c      gas_length = 4.0   ! In meters
      gas_length = 1.5   ! In meters
c     ================================
c
      deltlam = alamb(2) - alamb(1)
      sin2t = 1.0 - 1.0/(an*an)
c
      sum_phot = 0.
      ref_prop = 0.
c
      do i = 1,46
c
        e_max  = etol/alamb(i)
        e_min  = etol/(alamb(i) + deltlam)
        delt_e = e_max - e_min
c
        phn(i) = acon * sin2t * delt_e   ! Number of emitted Cer. photons
c
        s = gas_length * 0.5 * alog(g_trans(i)*g_trans(i+1))
        trans = exp(s)
c        trans = 1.0
        trans = trans* 0.7 ! for aerogel
        qe = sqrt(qe_use(i)*qe_use(i+1))
        refl = sqrt(refl_use(i)*refl_use(i+1))
c
c       Without reflections:
c
c        refl = 1.
ccccc        refl = refl**(1.44)
c
        photn = phn(i) * qe             ! Quantum efficiency
     &  * trans                         ! gas transmissivity in 4.0 meter of gas 
     &  * refl * refl                          ! reflectivity.
        sum_phot = sum_phot + photn     ! Total number of Photoelectrons
c
        ref_prop = ref_prop + phn(i) * qe * trans  ! Without reflection efficiency
c
      end do
c
      ref_c = sum_phot/ref_prop
      alen = 1./ref_prop
c
      print *,'  MEAN reflection coefficient =',ref_c
      print *,'  MEAN number of PHOTOELECTRONS for 1 cm of gas = ',
     &       sum_phot
c      print *,'  MEAN lenght for 1 effective ph.e. =',alen,'  cm' 
*
      stop
      end
