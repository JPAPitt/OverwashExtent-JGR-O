% ------------------------
%      Fig4_Qualitative_Thickness
% ------------------------
%
%  Authored by Jordan Pitt 20/10/21
%
% Produce matrices to use in the overwash model - T(w,h,d) , R(w,h,d) , \zeta(w,-L,h,d), \zeta(w,L,h,d)
% these wil be used by the overwash + transmission model to predict extents
%
% In this example we choose floe parameters consistent with ice - varying
% thicknesses to generate dependence in Figure 4

close all;
clear all;

%Suppress warning
warning('off','all')

Floe_Diams = [0.7];
Floe_Thicknesses = linspace(0.0001,100,5000);


Model_Pers_All(1,1,:) = 10;


%Generate matrices of these values - FD for floe diameter -d, Ft for floe
%thickness - h, and P for periods for each
FD_Mat = repmat(Floe_Diams,1,size(Floe_Thicknesses,2),size(Model_Pers_All,3));
FT_Mat = repmat(Floe_Thicknesses,size(FD_Mat,1),1,size(FD_Mat,3));
P_Mat = repmat(Model_Pers_All,size(FD_Mat,1),size(FD_Mat,2),1);

%Coefficient matrices at each of the h,d and T/w
Ta_LB_Mat = zeros(size(Model_Pers_All));
Ra_LB_Mat = zeros(size(Model_Pers_All));
kS_LB_Mat = zeros(size(Model_Pers_All));
LPE_LB_Mat = zeros(size(Model_Pers_All));
RPE_LB_Mat = zeros(size(Model_Pers_All));


%Model parameters - using Luke's model
th_res=100;
SURGE=0;
% SURGE = 1;
terms_grn=100;
extra_pts=[];     
rigid = 4; 
n=1; %number of eigenvalues - I had to do this to avoid the NaNS from evanscent modes for very thick floes

%Physical parameters
Param = ParamDef_Oceanide(rigid); 
Param = ModParam_def(Param,1,n,extra_pts,terms_grn,th_res); 


%Physical Parameters - using Luke's model
Param.E = 6e9;
Param.nu = 0.3;
Param.bed = 1000;
Param.rho_0 = 1025;

%Save the Parameter values 
ParamCons.IceRho = 920;
ParamCons.VolFrac = 1;
ParamCons.PCRho = ParamCons.VolFrac*ParamCons.IceRho;
Param.rho = ParamCons.PCRho;
ParamCons.E = Param.E;
ParamCons.bed = Param.bed;
ParamCons.g = Param.g;
ParamCons.nu = Param.nu;
ParamCons.DRat = (1-Param.rho/Param.rho_0);


%Loop over thickness and diameter
for i1 = 1:size(FD_Mat,1)
    for i2 = 1:size(FD_Mat,2)
        
        %update physical parameters - using floe thickness and diameter
        Param.thickness = FT_Mat(i1,i2,1);
        Param.floe_diam = FD_Mat(i1,i2,1);
        L = Param.floe_diam/2;
        plateabove=Param.thickness*(1-Param.rho/Param.rho_0);
        Param.draft = Param.thickness.*Param.rho./Param.rho_0; 
        Param.D = Param.E.*Param.thickness.^3./(12*(1-Param.nu.^2));
        Param.beta = Param.D./(Param.g.*Param.rho_0);

        %vectors of coefficients
        Ta_LB = zeros(1,size(FD_Mat,3));
        Ra_LB = zeros(1,size(FD_Mat,3));
        LPE_LB = zeros(1,size(FD_Mat,3));
        RPE_LB = zeros(1,size(FD_Mat,3));
        kS_LB = zeros(1,size(FD_Mat,3));

        %Loop over periods
        for i3 = 1:size(FD_Mat,3)

            Freq = 1./P_Mat(i1,i2,i3);

            try
                out = fn_ElasticRaft2d('freq', Freq,Param,'disk',SURGE,0,0,1,0,'r',[-L,L]);
                TN = (out(1).value);
                RN = (out(2).value);
                Plate = out(3).value;
                k = out(4).value;

            catch
                TN = NaN;
                RN = NaN;
                Plate = [NaN,NaN];
                k = NaN;
            end

            Ta_LB(i3) = TN;
            Ra_LB(i3) = RN;
            kS_LB(i3) = k;
            LPE_LB(i3) = Plate(1);
            RPE_LB(i3) = Plate(2);

        end
        Model_Pers = reshape(P_Mat(1,1,:),1,[]);

        
        %Fill relevant matrices with the vector
        Ta_LB_Mat(i1,i2,:) = Ta_LB(:);
        Ra_LB_Mat(i1,i2,:) = Ra_LB(:);
        kS_LB_Mat(i1,i2,:) = kS_LB(:);
        LPE_LB_Mat(i1,i2,:) = LPE_LB(:);
        RPE_LB_Mat(i1,i2,:) = RPE_LB(:);

    end
end


%Combine Matrices into a common structure
LB_Out = {Ta_LB_Mat,Ra_LB_Mat,kS_LB_Mat,LPE_LB_Mat,RPE_LB_Mat};

% figure()
% plot(reshape(P_Mat(1,1,:),[],1),abs(Ta_LB))

%Write the matrix out
Dir1  = '../Outputs/Data/CoefficientMatrices/Fig4_Qual/';
File_Nm = [Dir1,'Thick_Dep.mat'];
MatFile_NM = strcat(File_Nm);
save(MatFile_NM,'FD_Mat','FT_Mat','P_Mat','LB_Out','ParamCons');
