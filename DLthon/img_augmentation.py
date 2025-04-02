import numpy as np
import tensorflow as tf
from tensorflow.keras.layers import Layer
from tensorflow.keras.utils import Sequence
import math
import random
from tqdm import tqdm

def apply_augmentation(
    image: np.ndarray, 
    augmentation_transforms: callable, 
    num_samples: int = 5
) -> np.ndarray:
    '''
    하나의 이미지 원본에 대한 여러장의 증강 이미지를 생성하는 함수
    
    Args
    -----
    image : np.ndarray
        인풋 이미지 (flattened 또는 H×W)
    augmentation_transforms : callable
        적용할 증강 방식
    num_samples : int
        증강 수량 (기본: 5장)
        
    Raises
    ------
    ValueError
        이미지 크기 또는 샘플 수가 다를 경우
        
    Returns
    -------
    augmented_images : NumPy array
        리스트에 담겨서 반환되는 증강 이미지들
    '''
    if num_samples <= 0:
        raise ValueError(f"num_samples must be positive, got {num_samples}")
    
    if not callable(augmentation_transforms):
        raise TypeError("augmentation_transforms must be callable")
    
    # NumPy를 텐서로 변환
    if isinstance(image, np.ndarray):
        if image.dtype == np.uint8:
            image = image.astype(np.float32) / 255.0
        elif image.dtype not in (np.float32, np.float64):
            raise ValueError(f"Unsupported dtype: {image.dtype}")
        else:
            image = image.astype(np.float32)
            
        # 이미지 형태(shape)에 대한 에러 핸들링: flattened or 2D square
        if image.ndim == 1:
            n = int(image.shape[0] ** 0.5)
            if n*n != image.shape[0]:
                raise ValueError(f"Flattened size {image.shape[0]} must be a perfect square")
            image = image.reshape(n, n)
        elif image.ndim == 2 and image.shape[0] != image.shape[1]:
            raise ValueError(f"Image must be square, got {image.shape}")
        elif image.ndim > 2:
            raise ValueError(f"Expected 1D or 2D input, got {image.shape}")
            
        # 텐서플로우 형식으로 변환 (batch, height, width, channels)
        image = tf.convert_to_tensor(image, dtype=tf.float32)
        image = tf.expand_dims(image, axis=-1)  # 채널 차원 추가
        image = tf.expand_dims(image, axis=0)   # 배치 차원 추가
    
    # 텐서 크기 검증 (1, H, H, 1)
    shape = tf.shape(image)
    if len(image.shape) != 4 or shape[1] != shape[2]:
        raise ValueError(f"Tensor must be 1xHxHx1 (square grayscale), got {image.shape}")
    
    # 증강 이미지 생성
    augmented_images = [
        augmentation_transforms(tf.identity(image)).numpy()[0, :, :, 0]
        for _ in tqdm(range(num_samples), desc="Generating augmentations")
    ]
    
    return augmented_images

class SaltAndPepperNoise(Layer):
    '''
    머신러닝에서 데이터 증강 기법으로 활용되는 salt & pepper noise를 추가하는 클래스
    입력된 확률에 따라 소금&후추 노이즈가 랜덤하게 텐서의 요소를 대체한다.
    0(pepper) or 1(salt)
    
    Parameters
    ----------
    prob: float, optional
        텐서의 각 요소가 노이즈(0 또는 1)로 대체될 확률
        0과 1 사이의 수만 입력 가능하다. (기본 0.05)
    '''
    def __init__(self, prob=0.05, **kwargs):
        super(SaltAndPepperNoise, self).__init__(**kwargs)
        self.prob = prob
    
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
            
        # 마스크 생성
        mask = tf.random.uniform(tf.shape(inputs)) < self.prob
        mask = tf.cast(mask, tf.float32)
        
        # Salt(1) 또는 Pepper(0) 랜덤하게 생성
        noise = tf.random.uniform(tf.shape(inputs), 0, 2, dtype=tf.float32)
        noise = tf.floor(noise)
        
        # 노이즈 적용
        return inputs * (1 - mask) + noise * mask
        
    def get_config(self):
        config = super(SaltAndPepperNoise, self).get_config()
        config.update({'prob': self.prob})
        return config

class GaussianNoise(Layer):
    '''
    머신러닝에서 데이터 증강 기법으로 활용되는 Gaussian Noise를 적용하는 클래스
    
    지정된 평균과 표준 편차를 갖는 정규 분포에서 샘플링된 랜덤 값을
    텐서 요소에 추가한다.
    
    Parameters
    -----------
    mean: float, optional
        가우시안 노이즈의 평균값 (기본 0.0)
    std: float, optional
        가우시안 노이즈의 표준 편차. 0 이상의 값이어야 하며, 음수일 수 없습니다. (기본 0.1)
    '''
    def __init__(self, mean=0.0, std=0.1, **kwargs):
        super(GaussianNoise, self).__init__(**kwargs)
        self.mean = mean
        self.std = std
        
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
            
        noise = tf.random.normal(tf.shape(inputs), mean=self.mean, stddev=self.std)
        return inputs + noise
        
    def get_config(self):
        config = super(GaussianNoise, self).get_config()
        config.update({'mean': self.mean, 'std': self.std})
        return config

class RandomAffine(Layer):
    '''
    이미지에 랜덤 아핀 변환을 적용하는 클래스
    
    Parameters
    ----------
    degrees: tuple of float, optional
        회전 각도 범위 (최소, 최대) (기본 (-10, 10))
    translate: tuple of float, optional
        이동 범위 (width_shift, height_shift), 0~1 사이 값 (기본 (0.1, 0.1))
    scale: tuple of float, optional 
        크기 조정 범위 (최소, 최대) (기본 (0.9, 1.1))
    shear: tuple of float, optional
        전단(비틀림) 각도 범위 (최소, 최대) (기본 (0, 0))
    fill: float, optional
        변환 후 빈 공간을 채울 값 (기본 0.0)
    '''
    def __init__(self, degrees=(-10, 10), translate=(0.1, 0.1), 
                 scale=(0.9, 1.1), shear=(0, 0), fill=0.0, **kwargs):
        super(RandomAffine, self).__init__(**kwargs)
        self.degrees = degrees
        self.translate = translate
        self.scale = scale
        self.shear = shear
        self.fill = fill
        
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
            
        batch_size = tf.shape(inputs)[0]
        height = tf.shape(inputs)[1]
        width = tf.shape(inputs)[2]
        
        # 회전 각도 생성
        angle = tf.random.uniform(shape=[batch_size], 
                                  minval=self.degrees[0], 
                                  maxval=self.degrees[1])
        angle = angle * math.pi / 180  # 라디안으로 변환
        
        # 이동 생성
        tx = tf.random.uniform(shape=[batch_size], 
                              minval=-self.translate[0], 
                              maxval=self.translate[0])
        ty = tf.random.uniform(shape=[batch_size], 
                              minval=-self.translate[1], 
                              maxval=self.translate[1])
        tx = tx * tf.cast(width, tf.float32)
        ty = ty * tf.cast(height, tf.float32)
        
        # 크기 조정 생성
        scale_x = tf.random.uniform(shape=[batch_size], 
                                   minval=self.scale[0], 
                                   maxval=self.scale[1])
        scale_y = scale_x  # 정방형 유지
        
        # 전단(비틀림) 각도 생성
        shear_x = tf.random.uniform(shape=[batch_size], 
                                   minval=self.shear[0], 
                                   maxval=self.shear[1])
        shear_x = shear_x * math.pi / 180  # 라디안으로 변환
        
        # 변환 적용
        transforms = []
        for i in range(batch_size):
            # 회전 변환 행렬
            cos_angle = tf.cos(angle[i])
            sin_angle = tf.sin(angle[i])
            
            # 전단(shear) 적용
            shear_factor = tf.tan(shear_x[i])
            
            # 변환 행렬 구성
            transform = [
                scale_x[i] * cos_angle, 
                scale_y[i] * (sin_angle + shear_factor * cos_angle),
                tx[i],
                -scale_x[i] * sin_angle, 
                scale_y[i] * (cos_angle - shear_factor * sin_angle), 
                ty[i],
                0.0, 0.0
            ]
            transforms.append(transform)
            
        transforms = tf.stack(transforms)
        
        # 변환 적용
        output = tf.raw_ops.ImageProjectiveTransformV3(
            images=inputs,
            transforms=transforms,
            output_shape=[height, width],
            interpolation="BILINEAR",
            fill_mode="CONSTANT",
            fill_value=self.fill
        )
        
        return output
    
    def get_config(self):
        config = super(RandomAffine, self).get_config()
        config.update({
            'degrees': self.degrees,
            'translate': self.translate,
            'scale': self.scale,
            'shear': self.shear,
            'fill': self.fill
        })
        return config

class RandomFlip(Layer):
    '''
    이미지를 랜덤하게 좌우 또는 상하 반전시키는 클래스
    
    Parameters
    ----------
    mode: str, optional
        'horizontal', 'vertical', or 'both' (기본 'horizontal')
    seed: int, optional
        랜덤 시드 (기본 None)
    '''
    def __init__(self, mode='horizontal', p=0.5, **kwargs):
        super(RandomFlip, self).__init__(**kwargs)
        self.mode = mode
        self.p = p
        self.seed = None
        
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
        
        # 수평 반전
        if self.mode in ['horizontal', 'both']:
            flip_horizontal = tf.random.uniform(shape=[], seed=self.seed) < self.p
            inputs = tf.cond(
                flip_horizontal,
                lambda: tf.image.flip_left_right(inputs),
                lambda: inputs
            )
        
        # 수직 반전  
        if self.mode in ['vertical', 'both']:
            flip_vertical = tf.random.uniform(shape=[], seed=self.seed) < self.p
            inputs = tf.cond(
                flip_vertical,
                lambda: tf.image.flip_up_down(inputs),
                lambda: inputs
            )
            
        return inputs
    
    def get_config(self):
        config = super(RandomFlip, self).get_config()
        config.update({
            'mode': self.mode,
            'p': self.p,
            'seed': self.seed
        })
        return config

class RandomBrightness(Layer):
    '''
    이미지의 밝기를 랜덤하게 조정하는 클래스
    
    Parameters
    ----------
    factor: float or tuple of float, optional
        밝기 조정 요소의 범위 (기본 0.2)
        - float인 경우: (-factor, factor) 범위에서 랜덤 값 적용
        - tuple인 경우: (min_factor, max_factor) 범위에서 랜덤 값 적용
    '''
    def __init__(self, factor=0.2, **kwargs):
        super(RandomBrightness, self).__init__(**kwargs)
        if isinstance(factor, (tuple, list)):
            self.min_factor, self.max_factor = factor
        else:
            self.min_factor, self.max_factor = -factor, factor
    
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
        
        factor = tf.random.uniform(
            shape=[], 
            minval=self.min_factor, 
            maxval=self.max_factor
        )
        
        return tf.image.adjust_brightness(inputs, delta=factor)
    
    def get_config(self):
        config = super(RandomBrightness, self).get_config()
        config.update({
            'factor': (self.min_factor, self.max_factor)
        })
        return config

class RandomContrast(Layer):
    '''
    이미지의 대비를 랜덤하게 조정하는 클래스
    
    Parameters
    ----------
    factor: float or tuple of float, optional
        대비 조정 요소의 범위 (기본 0.2)
        - float인 경우: (1-factor, 1+factor) 범위에서 랜덤 값 적용
        - tuple인 경우: (min_factor, max_factor) 범위에서 랜덤 값 적용
    '''
    def __init__(self, factor=0.2, **kwargs):
        super(RandomContrast, self).__init__(**kwargs)
        if isinstance(factor, (tuple, list)):
            self.min_factor, self.max_factor = factor
        else:
            self.min_factor, self.max_factor = 1 - factor, 1 + factor
    
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
        
        factor = tf.random.uniform(
            shape=[], 
            minval=self.min_factor, 
            maxval=self.max_factor
        )
        
        return tf.image.adjust_contrast(inputs, contrast_factor=factor)
    
    def get_config(self):
        config = super(RandomContrast, self).get_config()
        config.update({
            'factor': (self.min_factor, self.max_factor)
        })
        return config

class GaussianBlur(Layer):
    '''
    이미지에 가우시안 블러를 적용하는 클래스
    
    Parameters
    ----------
    kernel_size: int, optional
        블러 커널 크기 (기본: 3)
    sigma: float or tuple of float, optional
        시그마 값 또는 범위 (기본: (0.1, 2.0))
    '''
    def __init__(self, kernel_size=3, sigma=(0.1, 2.0), **kwargs):
        super(GaussianBlur, self).__init__(**kwargs)
        self.kernel_size = kernel_size
        if isinstance(sigma, (tuple, list)):
            self.sigma_min, self.sigma_max = sigma
        else:
            self.sigma_min, self.sigma_max = sigma, sigma
    
    def build(self, input_shape):
        self.channels = input_shape[-1]
        super(GaussianBlur, self).build(input_shape)
    
    def call(self, inputs, training=None):
        if training is None:
            training = tf.keras.backend.learning_phase()
            
        if not training:
            return inputs
        
        sigma = tf.random.uniform(
            shape=[], 
            minval=self.sigma_min,
            maxval=self.sigma_max
        )
        
        # 가우시안 커널 생성
        radius = self.kernel_size // 2
        x = tf.range(-radius, radius + 1, 1, dtype=tf.float32)
        x = tf.exp(-tf.pow(x, 2) / (2.0 * tf.pow(sigma, 2)))
        kernel = tf.einsum('i,j->ij', x, x)
        kernel = kernel / tf.reduce_sum(kernel)
        kernel = tf.tile(kernel[:, :, tf.newaxis, tf.newaxis], [1, 1, self.channels, 1])
        
        # 컨볼루션 적용
        outputs = tf.nn.depthwise_conv2d(
            inputs, 
            kernel, 
            strides=[1, 1, 1, 1], 
            padding='SAME'
        )
        
        return outputs
    
    def get_config(self):
        config = super(GaussianBlur, self).get_config()
        config.update({
            'kernel_size': self.kernel_size,
            'sigma': (self.sigma_min, self.sigma_max)
        })
        return config

class SequentialAugmentation:
    '''
    여러 증강 기법을 순차적으로 적용하는 클래스
    
    Parameters
    ----------
    transforms: list of callables
        적용할 변환들의 리스트
    '''
    def __init__(self, transforms):
        self.transforms = transforms
    
    def __call__(self, inputs):
        x = inputs
        for transform in self.transforms:
            x = transform(x, training=True)
        return x

class RandomChoice:
    '''
    주어진 변환 중 하나를 랜덤하게 적용하는 클래스
    
    Parameters
    ----------
    transforms: list of callables
        선택할 변환들의 리스트
    '''
    def __init__(self, transforms):
        self.transforms = transforms
    
    def __call__(self, inputs):
        idx = random.randint(0, len(self.transforms) - 1)
        return self.transforms[idx](inputs, training=True)

class RandomApply:
    '''
    주어진 확률로 변환을 적용하는 클래스
    
    Parameters
    ----------
    transforms: callable
        적용할 변환
    p: float, optional
        변환이 적용될 확률 (기본: 0.5)
    '''
    def __init__(self, transform, p=0.5):
        self.transform = transform
        self.p = p
    
    def __call__(self, inputs):
        if random.random() < self.p:
            return self.transform(inputs, training=True)
        return inputs

class ImageDataset(Sequence):
    '''
    Keras의 Sequence 인터페이스를 구현한 이미지 데이터셋 클래스
    
    Parameters
    ----------
    X: array-like
        NumPy 배열 형태의 입력 이미지. 1D(flattened square images) 또는 2D(square images)일 수 있습니다.
        예상 데이터 타입: uint8 (0-255) 또는 float32/float64 (0-1).
    Y: array-like, optional
        이미지에 해당하는 라벨. X와 길이가 같아야 합니다.(기본 None: 라벨 없음)
    transform: callable, optional
        각 이미지 텐서에 적용할 변환 함수
    batch_size: int, optional
        배치 크기 (기본: 32)
    shuffle: bool, optional
        에포크마다 데이터를 섞을지 여부 (기본: True)
    '''
    def __init__(self, X, Y=None, transform=None, batch_size=32, shuffle=True):
        self.X = np.asarray(X)
        self.Y = np.asarray(Y) if Y is not None else None
        self.transform = transform
        self.batch_size = batch_size
        self.shuffle = shuffle
        self.indices = np.arange(len(self.X))
        
        if Y is not None and len(X) != len(Y):
            raise ValueError(f"Length mismatch: X ({len(X)}), Y ({len(Y)})")
        if transform and not callable(transform):
            raise TypeError(f"transform must be callable, got {type(transform)}")
            
        if self.shuffle:
            np.random.shuffle(self.indices)
    
    def __len__(self):
        '''배치 개수 반환'''
        return int(np.ceil(len(self.X) / self.batch_size))
    
    def __getitem__(self, idx):
        '''배치 데이터 가져오기'''
        batch_indices = self.indices[idx * self.batch_size:(idx + 1) * self.batch_size]
        batch_x = [self._process_image(self.X[i]) for i in batch_indices]
        batch_x = np.stack(batch_x)
        
        if self.Y is not None:
            batch_y = self.Y[batch_indices]
            return batch_x, batch_y
        return batch_x
    
    def on_epoch_end(self):
        '''에포크 종료 시 호출되는 메서드'''
        if self.shuffle:
            np.random.shuffle(self.indices)
    
    def _process_image(self, x):
        '''이미지 전처리 메서드'''
        # 데이터 타입(dtype) 정규화
        if x.dtype == np.uint8:
            x = x.astype(np.float32) / 255.0
        elif x.dtype not in (np.float32, np.float64):
            raise ValueError(f"Unsupported dtype: {x.dtype}")
        else:
            x = x.astype(np.float32)
        
        # 데이터 형태(shape) 처리
        if x.ndim == 1:
            n = int(x.shape[0] ** 0.5)
            if n * n != x.shape[0]:
                raise ValueError(f"Flattened size {x.shape[0]} must be a perfect square")
            x = x.reshape(n, n)
        elif x.ndim == 2 and x.shape[0] != x.shape[1]:
            raise ValueError(f"2D input must be square, got {x.shape}")
        elif x.ndim > 2:
            raise ValueError(f"Expected 1D or 2D input, got shape {x.shape}")
        
        # 채널 차원 추가
        x = np.expand_dims(x, axis=-1)
        
        # 변환 적용
        if self.transform:
            # TensorFlow 텐서로 변환
            x_tensor = tf.convert_to_tensor(x, dtype=tf.float32)
            x_tensor = tf.expand_dims(x_tensor, 0)  # 배치 차원 추가
            x_tensor = self.transform(x_tensor)
            x = x_tensor.numpy()[0]  # 배치 차원 제거
        
        return x