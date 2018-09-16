%%%%%%%%%%%%%%%%%%%%%%%%
%Author: Bob Liao
%Email:codechaser@163.com
%%%%%%%%%%%%%%%%%%%%%%%%
function snr_ber_all()
    clear;
    %���������
    SNR = 0:0.5:20;
    %QPSK ������
    QPSK_BER = get_ber(4);
    %8QAM ������
    QAM8_BER = get_ber(8);
    %16QAM ������
    QAM16_BER = get_ber(16);
    close all;
    %��ͼ
    figure;
    semilogy(SNR,QPSK_BER,'mx-');
    hold on;
    semilogy(SNR,QAM8_BER,'go-');
    hold on;
    semilogy(SNR,QAM16_BER,'bd-');
    
    axis([0 20 10^-5 0.5])
    grid on
    %ͼ��
    legend('QPSK', '8QAM','16QAM');
    xlabel('SNR, dB');
    ylabel('BER');
    title('BER��SNR��ϵ����');
end

function ber = get_ber(M)
    rand('state',100);
    randn('state',100);
    %Ĭ�ϲ�����Ϊ1���������
    samp = 1;
    SNR = 0:0.5:20;
    %������������MΪ8ʱΪ������N�ܹ���3��������ѡ����M����8ʱ��N=999999
    N = 10^6;
    if M == 8
        N = N - 1;
    end
    %һ����Ԫ��λ��
    k = log2(M);
    %���������
    signal = rand(1,N) > 0.5;
    %��������ÿk�����з��鲢�����k�У�N/k�е���Ԫ����
    signal_k = reshape(signal,k,length(signal)/k);
    %ÿ����Ԫ����Ӧ��ת��Ϊ16���������ڵ���
    signal_de = bi2de(signal_k.','left-msb');
    %����MΪ4��8��16ʱ�ֱ����QPSK,8QAM,16QAM����
    signal_modulated = modulate(modem.qammod(M),signal_de);
    for ii = 1:length(SNR)
        %���Ը�˹��������
        signal_awgn = awgn(signal_modulated,SNR(ii),'measured');
        %��������������ӵ����ݣ������ʽӦ����Ʒ�ʽһ��
        signal_demodulated = demodulate(modem.qamdemod(M),signal_awgn);
        %�����������16������ת��Ϊ��������Ԫ����
        signal_bi = de2bi(signal_demodulated,'left-msb');
        %��Ԫ����ת������
        signal_re_k = reshape(signal_bi.',numel(signal_bi),1);
        %����biterr��������������BER
        [nber(ii),~] = biterr(signal,signal_re_k');
    end
    ber = nber / N;
end