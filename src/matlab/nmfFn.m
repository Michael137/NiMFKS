function [H, cost] = nmfFn(nmf_params, corpus_analysis, target_analysis)   

    nmf_alg = nmf_params.Algorithm;
    target_spect = target_analysis.STFT.S;
    corpus_spect = corpus_analysis.STFT.S;

    switch nmf_alg
        case 'Euclidean'
            [H, cost] = nmf_euclidean(nmf_params, target_spect, corpus_spect);
        case 'Divergence'
            [H, cost] = nmf_divergence(nmf_params, target_spect, corpus_spect);
    end
end